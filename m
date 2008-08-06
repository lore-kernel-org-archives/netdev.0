From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 21:03:53 +0200
Message-ID: <20080806190353.GB17174@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John P Poet <jppoet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60991 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758165AbYHFTD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:03:56 -0400
Content-Disposition: inline
In-Reply-To: <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John P Poet <jppoet@gmail.com> :
[...]
> Thank you for the response.  That DOES seem to fix the cold-boot issue.
> 
> Unfortunately, it does not fix the timeout problem.  I am still
> experiencing transmittion problems:

Does the patch below (on top of the current pile) make a difference ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c421bf6..348846f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -874,12 +874,9 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
-		mdio_write(ioaddr, 0x1f, 0x0000);
-		mdio_write(ioaddr, 0x0e, 0x0000);
-	}
+	/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_write(ioaddr, 0x0e, 0x0000);
 
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
-- 
Ueimor
