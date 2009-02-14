From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 33/43] drivers/net/tulip: fix sparse warning: symbol shadows
	an earlier one
Date: Sat, 14 Feb 2009 22:47:30 +0100
Message-ID: <20090214214707.24377.56661.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754105AbZBNVru@vger.kernel.org>
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Rename a local variable resp. remove a redundant variable and
while being at it use more unform loop constructs.

Fix this sparse warning:
  drivers/net/tulip/de4x5.c:3944:13: warning: symbol 'i' shadows an earlier one
  drivers/net/tulip/de4x5.c:3938:9: originally declared here
  drivers/net/tulip/media.c:72:21: warning: symbol 'i' shadows an earlier one
  drivers/net/tulip/media.c:54:13: originally declared here
  drivers/net/tulip/media.c:134:21: warning: symbol 'i' shadows an earlier one
  drivers/net/tulip/media.c:117:13: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/tulip/de4x5.c |    4 ++--
 drivers/net/tulip/media.c |    8 +++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 98e8682..6430a2e 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -3942,8 +3942,8 @@ PCI_signature(char *name, struct de4x5_private *lp)
 	strcpy(name, "DE434/5");
 	return status;
     } else {                           /* Search for a DEC name in the SROM */
-	int i = *((char *)&lp->srom + 19) * 3;
-	strncpy(name, (char *)&lp->srom + 26 + i, 8);
+	int tmp = *((char *)&lp->srom + 19) * 3;
+	strncpy(name, (char *)&lp->srom + 26 + tmp, 8);
     }
     name[8] = '\0';
     for (i=0; i<siglen; i++) {
diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index 91cf9c8..daddfa5 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
@@ -69,11 +69,10 @@ int tulip_mdio_read(struct net_device *dev, int phy_id, int location)
 
 	spin_lock_irqsave(&tp->mii_lock, flags);
 	if (tp->chip_id == LC82C168) {
-		int i = 1000;
 		iowrite32(0x60020000 + (phy_id<<23) + (location<<18), ioaddr + 0xA0);
 		ioread32(ioaddr + 0xA0);
 		ioread32(ioaddr + 0xA0);
-		while (--i > 0) {
+		for (i = 1000; i >= 0; --i) {
 			barrier();
 			if ( ! ((retval = ioread32(ioaddr + 0xA0)) & 0x80000000))
 				break;
@@ -131,13 +130,12 @@ void tulip_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 
 	spin_lock_irqsave(&tp->mii_lock, flags);
 	if (tp->chip_id == LC82C168) {
-		int i = 1000;
 		iowrite32(cmd, ioaddr + 0xA0);
-		do {
+		for (i = 1000; i >= 0; --i) {
 			barrier();
 			if ( ! (ioread32(ioaddr + 0xA0) & 0x80000000))
 				break;
-		} while (--i > 0);
+		}
 		spin_unlock_irqrestore(&tp->mii_lock, flags);
 		return;
 	}
