From: David Hollis <dhollis@davehollis.com>
Subject: Re: [Patch] Fix asix-based gigabit cards connecting to 10 or 100Mbs
 networks (resend)
Date: Wed, 05 Nov 2008 07:26:31 -0500
Message-ID: <1225887991.4056.9136.camel@dhollis-lnx>
References: <1295ed070811041928u30f84f32h910a32d4d19f1cce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pantelis Koukousoulas <pktoss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:58569 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649AbYKEM0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:26:37 -0500
Received: from smtp.davehollis.com ([72.64.146.94]) by vms173003.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0K9V00LJX18BT814@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 05 Nov 2008 06:26:35 -0600 (CST)
In-reply-to: <1295ed070811041928u30f84f32h910a32d4d19f1cce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-05 at 05:28 +0200, Pantelis Koukousoulas wrote:
> Sorry for the previous mail, I think this will go as plain text now.
> 
> Hi,
> This morning I mentioned a problem with my belkin card not connecting
> to my network.
> The following patch fixes this problem. It would be great to include
> this to 2.6.28.
> 
> Thanks,
> Pantelis
> 
> 
> Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
> f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
> Without this patch, the card is recognized and the interface is brought
> up fine, but no packets actually flow through the interface.
> 
> Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
> Cc: David Hollis <dhollis@davehollis.com>
Acked-by: David Hollis <dhollis@davehollis.com>

> 
> Index: linux-next/drivers/net/usb/
> asix.c
> ===================================================================
> --- linux-next.orig/drivers/net/usb/asix.c      2008-11-04
> 19:51:06.000000000 +0200
> +++ linux-next/drivers/net/usb/asix.c   2008-11-04 21:32:55.000000000 +0200
> @@ -1102,12 +1102,14 @@
>         mode = AX88178_MEDIUM_DEFAULT;
> 
>         if (ecmd.speed == SPEED_1000)
> -               mode |= AX_MEDIUM_GM | AX_MEDIUM_ENCK;
> +               mode |= AX_MEDIUM_GM;
>         else if (ecmd.speed == SPEED_100)
>                 mode |= AX_MEDIUM_PS;
>         else
>                 mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
> 
> +       mode |= AX_MEDIUM_ENCK;
> +
>         if (ecmd.duplex == DUPLEX_FULL)

