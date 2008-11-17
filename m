From: "Pantelis Koukousoulas" <pktoss@gmail.com>
Subject: [PATCH] Fix asix-based gigabit cards connecting to 10 or 100Mbs networks
Date: Mon, 17 Nov 2008 20:41:57 +0200
Message-ID: <1295ed070811171041j1258ec41kc6b1db61e83b628e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:36098 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbYKQSl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 13:41:58 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2546004rvb.1
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 10:41:57 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
 f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
 Without this patch, the card is recognized and the interface is brought
 up fine, but no packets actually flow through the interface.

 Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
 Acked-by: David Hollis <dhollis@davehollis.com>

 Index: linux-next/drivers/net/usb/
 asix.c
 ===================================================================
 --- linux-next.orig/drivers/net/usb/asix.c      2008-11-04
 19:51:06.000000000 +0200
 +++ linux-next/drivers/net/usb/asix.c   2008-11-04 21:32:55.000000000 +0200
 @@ -1102,12 +1102,14 @@
        mode = AX88178_MEDIUM_DEFAULT;

        if (ecmd.speed == SPEED_1000)
 -               mode |= AX_MEDIUM_GM | AX_MEDIUM_ENCK;
 +               mode |= AX_MEDIUM_GM;
        else if (ecmd.speed == SPEED_100)
                mode |= AX_MEDIUM_PS;
        else
                mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);

 +       mode |= AX_MEDIUM_ENCK;
 +
        if (ecmd.duplex == DUPLEX_FULL)
