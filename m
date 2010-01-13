From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Wed, 13 Jan 2010 12:56:17 +0100
Message-ID: <20100113115617.GA24818@basil.fritz.box>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932111Ab0AML42@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B4DA4F4.6060007@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2010 at 05:48:20AM -0500, William Allen Simpson wrote:
> Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff
> and header length assumptions.
>
> Reduces multiply/shifts, marginally improving speed.
>
> Removes redundant tcp header length checks before checksumming.

I wonder if this actually improves performance on x86. On x86 and several
other architecture there's a addressing mode which allows to scale 
numbers by small factors (like 4). So doing a *4 is very cheap.

That's likely cheaper than using another register for the scaled value,
especially on 32bit x86 which doesn't have many.

It's difficult to benchmark this code, but did you check that the code 
shrinks after applying this patch at least?

-andi
