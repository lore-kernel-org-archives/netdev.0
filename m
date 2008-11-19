From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PATCH] Fix asix-based gigabit cards connecting to 10 or 100Mbs
 networks
Date: Wed, 19 Nov 2008 13:23:37 -0500
Message-ID: <1227119017.4419.268.camel@dhollis-lnx>
References: <1295ed070811171041j1258ec41kc6b1db61e83b628e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Pantelis Koukousoulas <pktoss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:49558 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbYKSSXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 13:23:52 -0500
Received: from smtp.davehollis.com ([96.228.138.81])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0KAL00BGTF3H1Y83@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 19 Nov 2008 12:23:42 -0600 (CST)
In-reply-to: <1295ed070811171041j1258ec41kc6b1db61e83b628e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-17 at 20:41 +0200, Pantelis Koukousoulas wrote:
> Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
>  f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
>  Without this patch, the card is recognized and the interface is brought
>  up fine, but no packets actually flow through the interface.
> 

Please apply.

Thanks.

>  Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
>  Acked-by: David Hollis <dhollis@davehollis.com>
> 
>  Index: linux-next/drivers/net/usb/
>  asix.c
>  ===================================================================
>  --- linux-next.orig/drivers/net/usb/asix.c      2008-11-04
>  19:51:06.000000000 +0200
>  +++ linux-next/drivers/net/usb/asix.c   2008-11-04 21:32:55.000000000 +0200
>  @@ -1102,12 +1102,14 @@
>         mode = AX88178_MEDIUM_DEFAULT;
> 
>         if (ecmd.speed == SPEED_1000)
>  -               mode |= AX_MEDIUM_GM | AX_MEDIUM_ENCK;
>  +               mode |= AX_MEDIUM_GM;
>         else if (ecmd.speed == SPEED_100)
>                 mode |= AX_MEDIUM_PS;
>         else
>                 mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
> 
>  +       mode |= AX_MEDIUM_ENCK;
>  +
>         if (ecmd.duplex == DUPLEX_FULL)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

