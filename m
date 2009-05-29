From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] mac8390: fix build with NET_POLL_CONTROLLER
Date: Sat, 30 May 2009 01:25:37 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0905300053001.22890@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0905281454450.9036@loopy.telegraphics.com.au>
 <20090527.223355.118242797.davem@davemloft.net>
 <Pine.LNX.4.64.0905282200460.12066@loopy.telegraphics.com.au>
 <20090529.015608.21828664.davem@davemloft.net>
 <20090529120357.GC3492@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, geert.uytterhoeven@gmail.com,
	shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20090529120357.GC3492@psychotron.englab.brq.redhat.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 29 May 2009, Jiri Pirko wrote:

> Fri, May 29, 2009 at 10:56:08AM CEST, davem@davemloft.net wrote:
> >From: Finn Thain <fthain@telegraphics.com.au>
> >Date: Thu, 28 May 2009 22:05:53 +1000 (EST)
> >
> >> --- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
> >> +++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
> >> @@ -489,7 +489,7 @@
> >>  	.ndo_set_mac_address 	= eth_mac_addr,
> >>  	.ndo_change_mtu		= eth_change_mtu,
> >>  #ifdef CONFIG_NET_POLL_CONTROLLER
> >> -	.ndo_poll_controller	= ei_poll,
> >> +	.ndo_poll_controller	= __ei_poll,
> >>  #endif
> >>  };
> >
> >I don't think this is a patch to drivers/net/Makefile :-)
> :)) Good one.. I wonder how this can happen ;)


*blush*

It happens like this... imagine you are using someone else's computer, you 
have a simple one line patch to fix, and can't be bothered downloading 69 
MB of source... (let alone git clone)

$ vi p
$ curl 'http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=drivers/net/lib8390.c;h=789b6cb744b284ee08d4c749ab9fa210dc34170e' >m
$ patch <p
can't find file to patch at input line 8
Perhaps you should have used the -p or --strip option?
The text leading up to this was:
--------------------------
|
|Fix the build for CONFIG_NET_POLL_CONTROLLER.
|
|Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
|
|--- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
|+++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
--------------------------
File to patch: m
patching file m
$

> >
> >I've seen some patch screwups in my time, but this one
> >takes the cake as one of the most impressive ones :-)
> >
> >I'll fix it up by hand, but realize that this makes more
> >work for me.

Thanks. I'd hate to screw it up a 4th time!

I'll avoid shortcuts next time.

Finn
