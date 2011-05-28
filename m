From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH next 03/15] atm: Convert vmalloc/memset to vzalloc
Date: Sat, 28 May 2011 10:36:23 -0700
Message-ID: <116f5bfafcbf40c5bce65498e5ed6983be6c20c1.1306603968.git.joe@perches.com>
References: <cover.1306603968.git.joe@perches.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1306603968.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/idt77252.c |   11 ++++++-----
 drivers/atm/lanai.c    |    3 +--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 1f8d724..8d7b663 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3415,27 +3415,28 @@ init_card(struct atm_dev *dev)
 
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
index 4e8ba56..be57a14 100644
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
1.7.5.rc3.dirty
