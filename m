From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 11:29:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008112957.43394f3d.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnip@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <3F8455BE.8080300@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Oct 2003 13:21:50 -0500
Steve Modica <modica@sgi.com> wrote:

> The problem is that on the Altix platform they have to deal with unaligned 
> accesses via an exception handler.

You mean, ia64.

Has anyone optimized the unaligned trap handler on ia64 (perhaps
coding it in raw assembler) to see what the situation looks like then?

Nobody wants to ever comment on this...

> This extra memcpy when the buffer is not unaligned currently only impacts 5701 

But it affects all platforms, not just ones that ia64 which have
the unaligned trap cost.  For example, we _DEFINITELY_ don't want
to do what your patch causes to happen on x86.
