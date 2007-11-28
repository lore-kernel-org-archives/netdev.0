From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Stop phy code from returning success to unknown ioctls.
Date: Wed, 28 Nov 2007 19:56:34 +0000
Message-ID: <1196279794.30806.54.camel@pmac.infradead.org>
References: <1196273071.30806.46.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Domen Puncer <domen.puncer@telargo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, afleming@freescale.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:53958 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbXK1T4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 14:56:47 -0500
In-Reply-To: <1196273071.30806.46.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This kind of sucks, and prevents the Fedora installer from using the
device for network installs...

[root@efika phy]# iwconfig eth0                                                                                                                
Warning: Driver for device eth0 has been compiled with an ancient version                                                                      
of Wireless Extension, while this program support version 11 and later.                                                                        
Some things may be broken...                                                                                                                   
                                                                                                                                               
eth0        ESSID:off/any  Nickname:""                                                                                                         
          NWID:0  Channel:0  Access Point: 00:00:BF:81:14:E0                                                                                   
          Bit Rate:-1.08206e+06 kb/s   Sensitivity=0/0                                                                                         
          RTS thr:off   Fragment thr:off                                                                                                       
          Encryption key:<too big>                                                                                                             
          Power Management:off                                                                                                                 
                                                                                                                                               
Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 9bc1177..7c9e6e3 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -406,6 +406,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 				&& phydev->drv->config_init)
 			phydev->drv->config_init(phydev);
 		break;
+
+	default:
+		return -ENOTTY;
 	}
 
 	return 0;

-- 
dwmw2

