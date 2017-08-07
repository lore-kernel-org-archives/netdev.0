From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next] net: dsa: lan9303: Only allocate 3 ports
Date: Tue,  8 Aug 2017 00:22:21 +0200
Message-ID: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save 2628 bytes on arm eabi by allocate only the required 3 ports.

Now that ds->num_ports is correct: In net/dsa/tag_lan9303.c
eliminate duplicate LAN9303_MAX_PORTS, use ds->num_ports.
(Matching the pattern of other net/dsa/tag_xxx.c files.)

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 2 +-
 net/dsa/tag_lan9303.c          | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 15befd155251..46fc1d5d3c9e 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -811,7 +811,7 @@ static struct dsa_switch_ops lan9303_switch_ops = {
 
 static int lan9303_register_switch(struct lan9303 *chip)
 {
-	chip->ds = dsa_switch_alloc(chip->dev, DSA_MAX_PORTS);
+	chip->ds = dsa_switch_alloc(chip->dev, LAN9303_NUM_PORTS);
 	if (!chip->ds)
 		return -ENOMEM;
 
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 247774d149f9..e23e7635fa00 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -39,7 +39,6 @@
  */
 
 #define LAN9303_TAG_LEN 4
-#define LAN9303_MAX_PORTS 3
 
 static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -104,7 +103,7 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	source_port = ntohs(lan9303_tag[1]) & 0x3;
 
-	if (source_port >= LAN9303_MAX_PORTS) {
+	if (source_port >= ds->num_ports) {
 		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid source port\n");
 		return NULL;
 	}
-- 
2.11.0
