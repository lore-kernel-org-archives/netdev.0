From: "Pantelis Koukousoulas" <pktoss@gmail.com>
Subject: [Patch] Fix asix-based gigabit cards connecting to 10 or 100Mbs networks (resend)
Date: Wed, 5 Nov 2008 05:28:10 +0200
Message-ID: <1295ed070811041928u30f84f32h910a32d4d19f1cce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.233]:35782 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbYKED2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 22:28:12 -0500
Received: by qb-out-0506.google.com with SMTP id f11so1633097qba.17
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2008 19:28:11 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the previous mail, I think this will go as plain text now.

Hi,
This morning I mentioned a problem with my belkin card not connecting
to my network.
The following patch fixes this problem. It would be great to include
this to 2.6.28.

Thanks,
Pantelis


Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
Without this patch, the card is recognized and the interface is brought
up fine, but no packets actually flow through the interface.

Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
Cc: David Hollis <dhollis@davehollis.com>

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
