From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: NAPI poll routine happens in interrupt context?
Date: Wed, 17 Aug 2005 19:18:35 +0100
Message-ID: <20050817181835.GE2667@linux-mips.org>
References: <200508170932.10441.Joshua.Wise@sicortex.com> <20050817094317.3437607e@dxpl.pdx.osdl.net> <200508171321.20094.Joshua.Wise@sicortex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	Aaron Brooks <aaron.brooks@sicortex.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751194AbVHQSTO@vger.kernel.org>
To: Joshua Wise <Joshua.Wise@sicortex.com>
Content-Disposition: inline
In-Reply-To: <200508171321.20094.Joshua.Wise@sicortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 17, 2005 at 01:21:18PM -0400, Joshua Wise wrote:

> > The bug is that ipv6 is doing an operation to handle MIB statistics and
> > the MIPS architecture math routines seem to need to sleep.

Except nothing in the network stack is using fp - the use of FP inside the
MIPS kernel is not supported in any way.  What happend is probably the
fetching of the opcode of the instruction in the branch delay slot of
the unaligned instruction emulator blew up because it uses a get_user which
again calls might_sleep and that won't exactly work if not called from
process context.

  Ralf
