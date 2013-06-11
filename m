From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] tun: Report "persist" flag to userspace
Date: Tue, 11 Jun 2013 14:41:24 +0400
Message-ID: <51B6FED4.6090703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:8356 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab3FKKle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 06:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TUN_PERSIST flag is not reported at all -- both TUNGETIFF, and sysfs
"flags" attribute skip one. Knowing whether a device is persistent or not
is critical for checkpoint-restore, thus I propose to add the read-only
IFF_PERSIST one for this.

Setting this new IFF_PERSIST is hardly possible, as TUNSETIFF doesn't check
for unknown flags being zero and thus there can be trash.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 89776c5..b90a731 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1530,6 +1530,9 @@ static int tun_flags(struct tun_struct *tun)
 	if (tun->flags & TUN_TAP_MQ)
 		flags |= IFF_MULTI_QUEUE;
 
+	if (tun->flags & TUN_PERSIST)
+		flags |= IFF_PERSIST;
+
 	return flags;
 }
 
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 2835b85..82334f8 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -68,6 +68,8 @@
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
+/* read-only flag */
+#define IFF_PERSIST	0x0800
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
