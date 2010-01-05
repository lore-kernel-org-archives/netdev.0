From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/wimax/i2400m/fw.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 10:01:54 -0700
Message-ID: <201001051001.55024.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755108Ab0AERDv@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 64cdfeb..e803a7d 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1041,21 +1041,14 @@ int i2400m_read_mac_addr(struct i2400m *i2400m)
 		dev_err(dev, "BM: read mac addr failed: %d\n", result);
 		goto error_read_mac;
 	}
-	d_printf(2, dev,
-		 "mac addr is %02x:%02x:%02x:%02x:%02x:%02x\n",
-		 ack_buf.ack_pl[0], ack_buf.ack_pl[1],
-		 ack_buf.ack_pl[2], ack_buf.ack_pl[3],
-		 ack_buf.ack_pl[4], ack_buf.ack_pl[5]);
+	d_printf(2, dev, "mac addr is %pM\n", ack_buf.ack_pl);
 	if (i2400m->bus_bm_mac_addr_impaired == 1) {
 		ack_buf.ack_pl[0] = 0x00;
 		ack_buf.ack_pl[1] = 0x16;
 		ack_buf.ack_pl[2] = 0xd3;
 		get_random_bytes(&ack_buf.ack_pl[3], 3);
 		dev_err(dev, "BM is MAC addr impaired, faking MAC addr to "
-			"mac addr is %02x:%02x:%02x:%02x:%02x:%02x\n",
-			ack_buf.ack_pl[0], ack_buf.ack_pl[1],
-			ack_buf.ack_pl[2], ack_buf.ack_pl[3],
-			ack_buf.ack_pl[4], ack_buf.ack_pl[5]);
+			"mac addr is %pM\n", ack_buf.ack_pl);
 		result = 0;
 	}
 	net_dev->addr_len = ETH_ALEN;
