From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 09:52:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310175200.GA9531@bougret.hpl.hp.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <404F5097.4040406@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 12:29:59PM -0500, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >On Wed, Mar 10, 2004 at 04:55:48PM +0000, Christoph Hellwig wrote:
> >>+MODULE_PARM(init_mode, "i");
> >>+MODULE_PARM_DESC(init_mode,
> >>+		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client 
> >>(Default)\n3: Master / Access Point\n4: Repeater (Not supported yet)\n5: 
> >>Secondary (Not supported yet)\n6: Monitor");
> >>
> >>	Please use module_param
> >
> >
> >	I would even say that this is useless because the driver
> >support WE, and WE scripts set the mode before the card is up.
> 
> module_param() is a type-safe interface roughly identical to 
> MODULE_PARM().  Therefore, if MODULE_PARM() works, module_param() works 
> also.

	Yes, I know, I've been doing that for IrDA. What I meant was
that this specific module parameter could be remove entirely because
redundant.

> >>diff -Naur -X /home/mcgrof/lib/dontdiff 
> >>linux-2.6.3/drivers/net/wireless/prism54/isl_wds.c 
> >>linux-2.6.3-prism54/drivers/net/wireless/prism54/isl_wds.c
> >>--- linux-2.6.3/drivers/net/wireless/prism54/isl_wds.c	Thu Jan  1 
> >>00:00:00 1970
> >>+++ linux-2.6.3-prism54/drivers/net/wireless/prism54/isl_wds.c	Thu 
> >>Mar  4 02:00:01 2004
> >>
> >>	WDS doesn't belong into a driver but in higher-level code.
> >
> >
> >	The big 802.11 reorg can only happen when HostAP is in the
> >kernel.
> 
> ISTR it needed some cleaning up before it could go in.

	I think it would be nice to give some more explicit feedback
to Jouni.

> Further, in Linux, there is _never_ a requirement that "this driver be 
> included before we can clean up."  You can start the re-org any time you 
> wish.  Out-of-tree maintainers can follow the re-org, sometimes more easily.

	You misunderstood. The HostAP driver has a pretty much
complete generic 802.11 stack. However, other driver can't depend on
that code until it's in the kernel.
	By "big 802.11 reorg", I meant "make the other driver depend
on HostAP 802.11 code".
	Of course, I'm quite partial to the HostAP code because I'm
more familiar with it and I believe it's the most advanced (host WEP,
802.1x, WPA, AP...). Other candidated are linux-wlan-ng or the *BSD
stack (by the way of the MadWifi driver).

> 	Jeff
> 
> 
> 
> P.S. I still need to look at your netlink thing.  Seems like a decent 
> direction.

	Thanks ;-) I would need to make sure that there is no popular
driver still using the old driver API (orinoco_cs is converted in the
CVS).

	Jean
