From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] macsec: fix crypto Kconfig dependency
Date: Sun, 17 Apr 2016 11:19:55 +0200
Message-ID: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new MACsec driver uses the AES crypto algorithm, but can be configured
even if CONFIG_CRYPTO is disabled, leading to a build error:

warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
crypto/built-in.o: In function `gcm_enc_copy_hash':
aes_generic.c:(.text+0x2b8): undefined reference to `crypto_xor'
aes_generic.c:(.text+0x2dc): undefined reference to `scatterwalk_map_and_copy'

This adds an explicit 'select CRYPTO' statement the way that other
drivers handle it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
---
 drivers/net/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2a1ba62b7da2..a24c18eee598 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -195,6 +195,7 @@ config GENEVE
 
 config MACSEC
 	tristate "IEEE 802.1AE MAC-level encryption (MACsec)"
+	select CRYPTO
 	select CRYPTO_AES
 	select CRYPTO_GCM
 	---help---
-- 
2.7.0
