From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 28/43] drivers/net/skfp: fix sparse warning: Should it be
	static?
Date: Sat, 14 Feb 2009 22:43:15 +0100
Message-ID: <20090214214210.24377.32244.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752145AbZBNVnh@vger.kernel.org>
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Move function declarations to header file.

Fix this sparse warnings:
  drivers/net/skfp/cfm.c:146:6: warning: symbol 'all_selection_criteria' was not declared. Should it be static?
  drivers/net/skfp/drvfbi.c:186:6: warning: symbol 'mac1_irq' was not declared. Should it be static?
  drivers/net/skfp/drvfbi.c:284:6: warning: symbol 'read_address' was not declared. Should it be static?
  drivers/net/skfp/drvfbi.c:323:6: warning: symbol 'init_board' was not declared. Should it be static?
  drivers/net/skfp/fplustm.c:72:24: warning: symbol 'fddi_broadcast' was not declared. Should it be static?
  drivers/net/skfp/fplustm.c:679:6: warning: symbol 'mac2_irq' was not declared. Should it be static?
  drivers/net/skfp/fplustm.c:805:6: warning: symbol 'mac3_irq' was not declared. Should it be static?
  drivers/net/skfp/fplustm.c:856:5: warning: symbol 'init_fplus' was not declared. Should it be static?
  drivers/net/skfp/pcmplc.c:404:6: warning: symbol 'init_plc' was not declared. Should it be static?
  drivers/net/skfp/pcmplc.c:1592:5: warning: symbol 'pcm_status_twisted' was not declared. Should it be static?
  drivers/net/skfp/smtinit.c:68:5: warning: symbol 'init_smt' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/skfp/h/smc.h  |   17 +++++++++++++++++
 drivers/net/skfp/hwmtm.c  |    9 ---------
 drivers/net/skfp/pcmplc.c |    3 ---
 drivers/net/skfp/skfddi.c |    3 ---
 drivers/net/skfp/smt.c    |   10 ----------
 5 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/skfp/h/smc.h b/drivers/net/skfp/h/smc.h
index 9432591..1758d95 100644
--- a/drivers/net/skfp/h/smc.h
+++ b/drivers/net/skfp/h/smc.h
@@ -467,5 +467,22 @@ struct s_smc {
 #endif	/* DEBUG_BRD && DEBUG */
 } ;
 
+extern const struct fddi_addr fddi_broadcast;
+
+extern void all_selection_criteria(struct s_smc *smc);
+extern void card_stop(struct s_smc *smc);
+extern void init_board(struct s_smc *smc, u_char *mac_addr);
+extern int init_fplus(struct s_smc *smc);
+extern void init_plc(struct s_smc *smc);
+extern int init_smt(struct s_smc *smc, u_char * mac_addr);
+extern void mac1_irq(struct s_smc *smc, u_short stu, u_short stl);
+extern void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l);
+extern void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l);
+extern int pcm_status_twisted(struct s_smc *smc);
+extern void plc1_irq(struct s_smc *smc);
+extern void plc2_irq(struct s_smc *smc);
+extern void read_address(struct s_smc *smc, u_char * mac_addr);
+extern void timer_irq(struct s_smc *smc);
+
 #endif	/* _SCMECM_ */
 
diff --git a/drivers/net/skfp/hwmtm.c b/drivers/net/skfp/hwmtm.c
index 4218e97..d322f1b 100644
--- a/drivers/net/skfp/hwmtm.c
+++ b/drivers/net/skfp/hwmtm.c
@@ -97,23 +97,15 @@ static void mac_drv_clear_txd(struct s_smc *smc);
 
 extern void* mac_drv_get_space(struct s_smc *smc, unsigned int size);
 extern void* mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size);
-extern void init_board(struct s_smc *smc, u_char *mac_addr);
 extern void mac_drv_fill_rxd(struct s_smc *smc);
-extern void plc1_irq(struct s_smc *smc);
 extern void mac_drv_tx_complete(struct s_smc *smc,
 				volatile struct s_smt_fp_txd *txd);
-extern void plc2_irq(struct s_smc *smc);
-extern void mac1_irq(struct s_smc *smc, u_short stu, u_short stl);
-extern void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l);
-extern void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l);
-extern void timer_irq(struct s_smc *smc);
 extern void mac_drv_rx_complete(struct s_smc *smc,
 				volatile struct s_smt_fp_rxd *rxd,
 				int frag_count, int len);
 extern void mac_drv_requeue_rxd(struct s_smc *smc, 
 				volatile struct s_smt_fp_rxd *rxd,
 				int frag_count);
-extern void init_plc(struct s_smc *smc);
 extern void mac_drv_clear_rxd(struct s_smc *smc,
 			      volatile struct s_smt_fp_rxd *rxd, int frag_count);
 
@@ -136,7 +128,6 @@ extern void dma_complete(struct s_smc *smc, volatile union s_fp_descr *descr,
 			 int flag);
 #endif
 
-extern int init_fplus(struct s_smc *smc);
 extern int mac_drv_rx_init(struct s_smc *smc, int len, int fc, char *look_ahead,
 			   int la_len);
 
diff --git a/drivers/net/skfp/pcmplc.c b/drivers/net/skfp/pcmplc.c
index 74e129f..f1df2ec 100644
--- a/drivers/net/skfp/pcmplc.c
+++ b/drivers/net/skfp/pcmplc.c
@@ -198,9 +198,6 @@ static int plc_imsk_na = PL_PCM_CODE | PL_TRACE_PROP | PL_PCM_BREAK |
 static const int plc_imsk_act = PL_PCM_CODE | PL_TRACE_PROP | PL_PCM_BREAK |
 			PL_PCM_ENABLED | PL_SELF_TEST | PL_EBUF_ERR;
 
-/* external functions */
-void all_selection_criteria(struct s_smc *smc);
-
 /* internal functions */
 static void pcm_fsm(struct s_smc *smc, struct s_phy *phy, int cmd);
 static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy);
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 9a00e55..e14aec0 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -135,14 +135,11 @@ void dump_data(unsigned char *Data, int length);
 
 // External functions from the hardware module
 extern u_int mac_drv_check_space(void);
-extern void read_address(struct s_smc *smc, u_char * mac_addr);
-extern void card_stop(struct s_smc *smc);
 extern int mac_drv_init(struct s_smc *smc);
 extern void hwm_tx_frag(struct s_smc *smc, char far * virt, u_long phys,
 			int len, int frame_status);
 extern int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count,
 		       int frame_len, int frame_status);
-extern int init_smt(struct s_smc *smc, u_char * mac_addr);
 extern void fddi_isr(struct s_smc *smc);
 extern void hwm_rx_frag(struct s_smc *smc, char far * virt, u_long phys,
 			int len, int frame_status);
diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 805383b..83d16fe 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -55,16 +55,6 @@ static const struct fddi_addr SMT_Unknown = {
 } ;
 
 /*
- * external variables
- */
-extern const struct fddi_addr fddi_broadcast ;
-
-/*
- * external functions
- */
-int pcm_status_twisted(struct s_smc *smc);
-
-/*
  * function prototypes
  */
 #ifdef	LITTLE_ENDIAN
