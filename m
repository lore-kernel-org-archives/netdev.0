From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: link state detection for 8139too against 2.4.20rc2 / 2.5
Date: Wed, 27 Nov 2002 23:58:38 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE5A27E.50207@pobox.com>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com> <3DA96BCC.B2589AC0@isg.de> <3DE0CA4C.730699FC@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:

> Hi,
>
>
> >>Uhmmm, you don't need to poll with the rtl8139.  There is a link change
> >>interrupt.  Here is the recently added from rtl8139.c
> >
> >ok, I'll try this next time I have access to the card.
>
>
> ...that was some days ago. I've seen that Jeff is enhancing the MII
> interface library, so I used the functions provided there. Patch is
> against 2.4.20rc2 and 2.5 with some offset. Please apply if it looks
> good.
>
> Cheers, Stefan
>
>
> ------------------------------------------------------------------------
>
> --- linux/drivers/net/8139too.c.old	2002-11-19 00:32:04.000000000 +0100
> +++ linux/drivers/net/8139too.c	2002-11-21 22:32:39.000000000 +0100
> @@ -1335,18 +1335,7 @@
>  	struct rtl8139_private *tp = dev->priv;
>
>  	if (tp->phys[0] >= 0) {
> -		u16 mii_lpa = mdio_read(dev, tp->phys[0], MII_LPA);
> -		if (mii_lpa == 0xffff)
> -			;					/* Not there */
> -		else if ((mii_lpa & LPA_100FULL) == LPA_100FULL
> -				 || (mii_lpa & 0x00C0) == LPA_10FULL)
> -			tp->mii.full_duplex = 1;
> -
> -		printk (KERN_INFO"%s: Setting %s%s-duplex based on"
> -				" auto-negotiated partner ability %4.4x.\n",
> -		        dev->name, mii_lpa == 0 ? "" :
> -				(mii_lpa & 0x0180) ? "100mbps " : "10mbps ",
> -			tp->mii.full_duplex ? "full" : "half", mii_lpa);
> +		mii_check_media(&tp->mii, 1, 1);



close -- you don't want to unconditionally "initialize" the media 
(mii_check_media second arg).

You can also kibbitz from 8139cp.c in 2.4.20-rc4 / 2.5.<recent> because 
the phy code is gonna be pretty darned similar.  Eventually the phy code 
needs to move to a common 8139lib.c, because both old-8139 line and 
8139C+ support external MII phys as well as the normal on-chip phy found 
in most 8139s.

	Jeff
