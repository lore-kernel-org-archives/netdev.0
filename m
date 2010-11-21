From: Joe Perches <joe@perches.com>
Subject: [PATCH 48/62] wan: Use static const
Date: Sat, 20 Nov 2010 18:38:49 -0800
Message-ID: <e76dc736a1a7144c9a39bf9e223fd857250984c4.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  20550	    335	   4688	  25573	   63e5	drivers/net/wan/dscc4.o.old
  20518	    335	   4688	  25541	   63c5	drivers/net/wan/dscc4.o.new

Changed dscc4_match to take a const struct thingie *p
(No, I didn't name that struct...)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/dscc4.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 94ff9b0..4578e5b 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1358,7 +1358,7 @@ static int dscc4_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return ret;
 }
 
-static int dscc4_match(struct thingie *p, int value)
+static int dscc4_match(const struct thingie *p, int value)
 {
 	int i;
 
@@ -1403,7 +1403,7 @@ done:
 static int dscc4_encoding_setting(struct dscc4_dev_priv *dpriv,
 				  struct net_device *dev)
 {
-	struct thingie encoding[] = {
+	static const struct thingie encoding[] = {
 		{ ENCODING_NRZ,		0x00000000 },
 		{ ENCODING_NRZI,	0x00200000 },
 		{ ENCODING_FM_MARK,	0x00400000 },
@@ -1442,7 +1442,7 @@ static int dscc4_loopback_setting(struct dscc4_dev_priv *dpriv,
 static int dscc4_crc_setting(struct dscc4_dev_priv *dpriv,
 			     struct net_device *dev)
 {
-	struct thingie crc[] = {
+	static const struct thingie crc[] = {
 		{ PARITY_CRC16_PR0_CCITT,	0x00000010 },
 		{ PARITY_CRC16_PR1_CCITT,	0x00000000 },
 		{ PARITY_CRC32_PR0_CCITT,	0x00000011 },
-- 
1.7.3.2.245.g03276.dirty
