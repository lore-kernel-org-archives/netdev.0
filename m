From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/49] drivers/atm: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:31 -0700
Message-ID: <e8478739350c39bf9f08dc6f66edcec8033a0e04.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/idt77252.c |   11 ++++++-----
 drivers/atm/lanai.c    |    3 +--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index bce5732..8c09e32 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3459,27 +3459,28 @@ init_card(struct atm_dev *dev)
 
 	size = sizeof(struct vc_map *) * card->tct_size;
 	IPRINTK("%s: allocate %d byte for VC map.\n", card->name, size);
-	if (NULL == (card->vcs = vmalloc(size))) {
+	card->vcs = vzalloc(size);
+	if (!card->vcs) {
 		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
-	memset(card->vcs, 0, size);
 
 	size = sizeof(struct vc_map *) * card->scd_size;
 	IPRINTK("%s: allocate %d byte for SCD to VC mapping.\n",
 	        card->name, size);
-	if (NULL == (card->scd2vc = vmalloc(size))) {
+	card->scd2vc = vzalloc(size);
+	if (!card->scd2vc) {
 		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
-	memset(card->scd2vc, 0, size);
 
 	size = sizeof(struct tst_info) * (card->tst_size - 2);
 	IPRINTK("%s: allocate %d byte for TST to VC mapping.\n",
 		card->name, size);
-	if (NULL == (card->soft_tst = vmalloc(size))) {
+	card->soft_tst = vmalloc(size);
+	if (!card->soft_tst) {
 		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index cbe15a8..5cec592 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -1457,10 +1457,9 @@ static int __devinit vcc_table_allocate(struct lanai_dev *lanai)
 	return (lanai->vccs == NULL) ? -ENOMEM : 0;
 #else
 	int bytes = (lanai->num_vci) * sizeof(struct lanai_vcc *);
-	lanai->vccs = (struct lanai_vcc **) vmalloc(bytes);
+	lanai->vccs = vzalloc(bytes);
 	if (unlikely(lanai->vccs == NULL))
 		return -ENOMEM;
-	memset(lanai->vccs, 0, bytes);
 	return 0;
 #endif
 }
-- 
1.7.3.1.g432b3.dirty
