From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 5/12] Host AP: Fix hw address changing for wifi# interface
Date: Sun, 7 Nov 2004 23:13:12 -0800
Message-ID: <20041108071312.GF1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update wifi# interface MAC address when changing addresses. Without
this, MAC address change does not work correctly with the new
interface design (wifi#/wlan0#).

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap.c b/drivers/net/wireless/hostap/hostap.c
--- a/drivers/net/wireless/hostap/hostap.c	2004-11-07 22:38:26 -08:00
+++ b/drivers/net/wireless/hostap/hostap.c	2004-11-07 22:38:26 -08:00
@@ -808,6 +808,7 @@
 		iface = list_entry(ptr, struct hostap_interface, list);
 		memcpy(iface->dev->dev_addr, addr->sa_data, ETH_ALEN);
 	}
+	memcpy(local->dev->dev_addr, addr->sa_data, ETH_ALEN);
 	read_unlock_bh(&local->iface_lock);
 
 	return 0;


-- 
Jouni Malinen                                            PGP id EFC895FA
