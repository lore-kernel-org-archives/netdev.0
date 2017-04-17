From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 22/25] net: pxa168_eth: Adjust four checks for null pointers
Date: Mon, 17 Apr 2017 17:32:16 +0200
Message-ID: <be75e4f2-8af8-6527-298c-1c5ceb3a0583@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 15:23:45 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 2404eac51c63..993724959a7c 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -556,11 +556,11 @@ static int init_hash_table(struct pxa168_eth_private *pep)
 	 * function.Driver can dynamically switch to them if the 1/2kB hash
 	 * table is full.
 	 */
-	if (pep->htpr == NULL) {
+	if (!pep->htpr) {
 		pep->htpr = dma_zalloc_coherent(pep->dev->dev.parent,
 						HASH_ADDR_TABLE_SIZE,
 						&pep->htpr_dma, GFP_KERNEL);
-		if (pep->htpr == NULL)
+		if (!pep->htpr)
 			return -ENOMEM;
 	} else {
 		memset(pep->htpr, 0, HASH_ADDR_TABLE_SIZE);
@@ -1356,7 +1356,7 @@ static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
 static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
 			       int cmd)
 {
-	if (dev->phydev != NULL)
+	if (dev->phydev)
 		return phy_mii_ioctl(dev->phydev, ifr, cmd);
 
 	return -EOPNOTSUPP;
@@ -1501,7 +1501,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	pep->timeout.data = (unsigned long)pep;
 
 	pep->smi_bus = mdiobus_alloc();
-	if (pep->smi_bus == NULL) {
+	if (!pep->smi_bus) {
 		err = -ENOMEM;
 		goto err_netdev;
 	}
-- 
2.12.2
