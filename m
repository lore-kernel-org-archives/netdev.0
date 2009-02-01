From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] sungem: limit reaches -1, but 0 tested
Date: Sun, 01 Feb 2009 18:15:27 +0100
Message-ID: <4985D8AF.1040009@gmail.com>
References: <4984473C.1040508@gmail.com> <20090201.015931.127677783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755053AbZBARPo@vger.kernel.org>
In-Reply-To: <20090201.015931.127677783.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Sat, 31 Jan 2009 13:42:36 +0100
> 
>> With a postfix decrement these reach -1 rather than 0,
>> but after the loop it is tested to have become 0.
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Just like the case just pointed out in your 'net' version
> of this patch, it is being tested "<= 0" so this fix
> is not necessary at all.

The change is correct although the changelog is not clear.
This is also true for the cassini patch, here included as well.

How about:

------------------>8----------------8<-------------------------
while (limit--)
	if (test())
		break;

if (limit <= 0)
	goto test_failed;

In the last iteration, limit is decremented after the test to 0.
If just thereafter test() succeeds and a break occurs, the goto
still occurs because limit is 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/cassini.c    |    4 ++--
 drivers/net/sungem_phy.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 840b3d1..bbbc3bb 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -806,7 +806,7 @@ static int cas_reset_mii_phy(struct cas *cp)
 
 	cas_phy_write(cp, MII_BMCR, BMCR_RESET);
 	udelay(100);
-	while (limit--) {
+	while (--limit) {
 		val = cas_phy_read(cp, MII_BMCR);
 		if ((val & BMCR_RESET) == 0)
 			break;
@@ -979,7 +979,7 @@ static void cas_phy_init(struct cas *cp)
 		writel(val, cp->regs + REG_PCS_MII_CTRL);
 
 		limit = STOP_TRIES;
-		while (limit-- > 0) {
+		while (--limit > 0) {
 			udelay(10);
 			if ((readl(cp->regs + REG_PCS_MII_CTRL) &
 			     PCS_MII_RESET) == 0)
diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 61843fd..78f8cee 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -79,7 +79,7 @@ static int reset_one_mii_phy(struct mii_phy* phy, int phy_id)
 
 	udelay(100);
 
-	while (limit--) {
+	while (--limit) {
 		val = __phy_read(phy, phy_id, MII_BMCR);
 		if ((val & BMCR_RESET) == 0)
 			break;
