From: tanxiaojun <tanxiaojun@huawei.com>
Subject: [PATCH] fddi: cleanup unsigned to unsigned int/short
Date: Fri, 13 Dec 2013 14:49:56 +0800
Message-ID: <52AAAE14.9000301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <arend@broadcom.com>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27558 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab3LMGuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 01:50:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "unsigned int/short" instead of "unsigned", and change the type of
iteration variable "i" to "unsigned int".

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 drivers/net/fddi/skfp/fplustm.c    | 24 +++++-----
 drivers/net/fddi/skfp/h/supern_2.h | 96 +++++++++++++++++++-------------------
 drivers/net/fddi/skfp/smt.c        |  2 +-
 drivers/net/fddi/skfp/srf.c        | 24 +++++-----
 4 files changed, 73 insertions(+), 73 deletions(-)

diff --git a/drivers/net/fddi/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
index f839935..d918d8a 100644
--- a/drivers/net/fddi/skfp/fplustm.c
+++ b/drivers/net/fddi/skfp/fplustm.c
@@ -55,14 +55,14 @@ static	char cam_warning [] = "E_SMT_004: CAM still busy\n";
 
 #define	DUMMY_READ()	smc->hw.mc_dummy = (u_short) inp(ADDR(B0_RAP))
 
-#define	CHECK_NPP() {	unsigned k = 10000 ;\
+#define	CHECK_NPP() {	unsigned int k = 10000 ;\
 			while ((inpw(FM_A(FM_STMCHN)) & FM_SNPPND) && k) k--;\
 			if (!k) { \
 				SMT_PANIC(smc,SMT_E0130, SMT_E0130_MSG) ; \
 			}	\
 		}
 
-#define	CHECK_CAM() {	unsigned k = 10 ;\
+#define	CHECK_CAM() {	unsigned int k = 10 ;\
 			while (!(inpw(FM_A(FM_AFSTAT)) & FM_DONE) && k) k--;\
 			if (!k) { \
 				SMT_PANIC(smc,SMT_E0131, SMT_E0131_MSG) ; \
@@ -356,25 +356,25 @@ static	void set_formac_addr(struct s_smc *smc)
 	long	t_requ = smc->mib.m[MAC0].fddiMACT_Req ;
 
 	outpw(FM_A(FM_SAID),my_said) ;	/* set short address */
-	outpw(FM_A(FM_LAIL),(unsigned)((smc->hw.fddi_home_addr.a[4]<<8) +
+	outpw(FM_A(FM_LAIL),(unsigned short)((smc->hw.fddi_home_addr.a[4]<<8) +
 					smc->hw.fddi_home_addr.a[5])) ;
-	outpw(FM_A(FM_LAIC),(unsigned)((smc->hw.fddi_home_addr.a[2]<<8) +
+	outpw(FM_A(FM_LAIC),(unsigned short)((smc->hw.fddi_home_addr.a[2]<<8) +
 					smc->hw.fddi_home_addr.a[3])) ;
-	outpw(FM_A(FM_LAIM),(unsigned)((smc->hw.fddi_home_addr.a[0]<<8) +
+	outpw(FM_A(FM_LAIM),(unsigned short)((smc->hw.fddi_home_addr.a[0]<<8) +
 					smc->hw.fddi_home_addr.a[1])) ;
 
 	outpw(FM_A(FM_SAGP),my_sagp) ;	/* set short group address */
 
-	outpw(FM_A(FM_LAGL),(unsigned)((smc->hw.fp.group_addr.a[4]<<8) +
+	outpw(FM_A(FM_LAGL),(unsigned short)((smc->hw.fp.group_addr.a[4]<<8) +
 					smc->hw.fp.group_addr.a[5])) ;
-	outpw(FM_A(FM_LAGC),(unsigned)((smc->hw.fp.group_addr.a[2]<<8) +
+	outpw(FM_A(FM_LAGC),(unsigned short)((smc->hw.fp.group_addr.a[2]<<8) +
 					smc->hw.fp.group_addr.a[3])) ;
-	outpw(FM_A(FM_LAGM),(unsigned)((smc->hw.fp.group_addr.a[0]<<8) +
+	outpw(FM_A(FM_LAGM),(unsigned short)((smc->hw.fp.group_addr.a[0]<<8) +
 					smc->hw.fp.group_addr.a[1])) ;
 
 	/* set r_request regs. (MSW & LSW of TRT ) */
-	outpw(FM_A(FM_TREQ1),(unsigned)(t_requ>>16)) ;
-	outpw(FM_A(FM_TREQ0),(unsigned)t_requ) ;
+	outpw(FM_A(FM_TREQ1),(unsigned short)(t_requ>>16)) ;
+	outpw(FM_A(FM_TREQ0),(unsigned short)t_requ) ;
 }
 
 static void set_int(char *p, int l)
@@ -394,10 +394,10 @@ static void set_int(char *p, int l)
  *	append 'end of chain' pointer
  */
 static void copy_tx_mac(struct s_smc *smc, u_long td, struct fddi_mac *mac,
-			unsigned off, int len)
+			unsigned int off, int len)
 /* u_long td;		 transmit descriptor */
 /* struct fddi_mac *mac; mac frame pointer */
-/* unsigned off;	 start address within buffer memory */
+/* unsigned int off;	 start address within buffer memory */
 /* int len ;		 length of the frame including the FC */
 {
 	int	i ;
diff --git a/drivers/net/fddi/skfp/h/supern_2.h b/drivers/net/fddi/skfp/h/supern_2.h
index 0b73690..4ee360d 100644
--- a/drivers/net/fddi/skfp/h/supern_2.h
+++ b/drivers/net/fddi/skfp/h/supern_2.h
@@ -92,33 +92,33 @@
 union rx_descr {
 	struct {
 #ifdef	LITTLE_ENDIAN
-	unsigned	rx_length :16 ;	/* frame length lower/upper byte */
-	unsigned	rx_erfbb  :2 ;	/* received frame byte boundary */
-	unsigned	rx_reserv2:2 ;	/* reserved */	
-	unsigned	rx_sfrmty :3 ;	/* frame type bits */
-	unsigned	rx_sadrrg :1 ;	/* DA == MA or broad-/multicast */
-	unsigned	rx_sfrmerr:1 ;	/* received frame not valid */
-	unsigned	rx_seac0  :1 ;	/* frame-copied  C-indicator */
-	unsigned	rx_seac1  :1 ;	/* address-match A-indicator */
-	unsigned	rx_seac2  :1 ;	/* frame-error   E-indicator */
-	unsigned	rx_ssrcrtg:1 ;	/* == 1 SA has MSB set */
-	unsigned	rx_reserv1:1 ;	/* reserved */	
-	unsigned	rx_msrabt :1 ;	/* memory status receive abort */
-	unsigned	rx_msvalid:1 ;	/* memory status valid */
+	unsigned int	rx_length :16 ;	/* frame length lower/upper byte */
+	unsigned int	rx_erfbb  :2 ;	/* received frame byte boundary */
+	unsigned int	rx_reserv2:2 ;	/* reserved */
+	unsigned int	rx_sfrmty :3 ;	/* frame type bits */
+	unsigned int	rx_sadrrg :1 ;	/* DA == MA or broad-/multicast */
+	unsigned int	rx_sfrmerr:1 ;	/* received frame not valid */
+	unsigned int	rx_seac0  :1 ;	/* frame-copied  C-indicator */
+	unsigned int	rx_seac1  :1 ;	/* address-match A-indicator */
+	unsigned int	rx_seac2  :1 ;	/* frame-error   E-indicator */
+	unsigned int	rx_ssrcrtg:1 ;	/* == 1 SA has MSB set */
+	unsigned int	rx_reserv1:1 ;	/* reserved */
+	unsigned int	rx_msrabt :1 ;	/* memory status receive abort */
+	unsigned int	rx_msvalid:1 ;	/* memory status valid */
 #else
-	unsigned	rx_msvalid:1 ;	/* memory status valid */
-	unsigned	rx_msrabt :1 ;	/* memory status receive abort */
-	unsigned	rx_reserv1:1 ;	/* reserved */	
-	unsigned	rx_ssrcrtg:1 ;	/* == 1 SA has MSB set */
-	unsigned	rx_seac2  :1 ;	/* frame-error   E-indicator */
-	unsigned	rx_seac1  :1 ;	/* address-match A-indicator */
-	unsigned	rx_seac0  :1 ;	/* frame-copied  C-indicator */
-	unsigned	rx_sfrmerr:1 ;	/* received frame not valid */
-	unsigned	rx_sadrrg :1 ;	/* DA == MA or broad-/multicast */
-	unsigned	rx_sfrmty :3 ;	/* frame type bits */
-	unsigned	rx_erfbb  :2 ;	/* received frame byte boundary */
-	unsigned	rx_reserv2:2 ;	/* reserved */	
-	unsigned	rx_length :16 ;	/* frame length lower/upper byte */
+	unsigned int	rx_msvalid:1 ;	/* memory status valid */
+	unsigned int	rx_msrabt :1 ;	/* memory status receive abort */
+	unsigned int	rx_reserv1:1 ;	/* reserved */
+	unsigned int	rx_ssrcrtg:1 ;	/* == 1 SA has MSB set */
+	unsigned int	rx_seac2  :1 ;	/* frame-error   E-indicator */
+	unsigned int	rx_seac1  :1 ;	/* address-match A-indicator */
+	unsigned int	rx_seac0  :1 ;	/* frame-copied  C-indicator */
+	unsigned int	rx_sfrmerr:1 ;	/* received frame not valid */
+	unsigned int	rx_sadrrg :1 ;	/* DA == MA or broad-/multicast */
+	unsigned int	rx_sfrmty :3 ;	/* frame type bits */
+	unsigned int	rx_erfbb  :2 ;	/* received frame byte boundary */
+	unsigned int	rx_reserv2:2 ;	/* reserved */
+	unsigned int	rx_length :16 ;	/* frame length lower/upper byte */
 #endif
 	} r ;
 	long	i ;
@@ -162,23 +162,23 @@ union rx_descr {
 union tx_descr {
 	struct {
 #ifdef	LITTLE_ENDIAN
-	unsigned	tx_length:16 ;	/* frame length lower/upper byte */
-	unsigned	tx_res	 :8 ;	/* reserved 	 (bit 16..23) */
-	unsigned	tx_xmtabt:1 ;	/* transmit abort */
-	unsigned	tx_nfcs  :1 ;	/* no frame check sequence */
-	unsigned	tx_xdone :1 ;	/* give up token */
-	unsigned	tx_rpxm  :2 ;	/* byte offset */
-	unsigned	tx_pat1  :2 ;	/* must be TXP1 */
-	unsigned	tx_more	 :1 ;	/* more frame in chain */
+	unsigned int	tx_length:16 ;	/* frame length lower/upper byte */
+	unsigned int	tx_res	 :8 ;	/* reserved 	 (bit 16..23) */
+	unsigned int	tx_xmtabt:1 ;	/* transmit abort */
+	unsigned int	tx_nfcs  :1 ;	/* no frame check sequence */
+	unsigned int	tx_xdone :1 ;	/* give up token */
+	unsigned int	tx_rpxm  :2 ;	/* byte offset */
+	unsigned int	tx_pat1  :2 ;	/* must be TXP1 */
+	unsigned int	tx_more	 :1 ;	/* more frame in chain */
 #else
-	unsigned	tx_more	 :1 ;	/* more frame in chain */
-	unsigned	tx_pat1  :2 ;	/* must be TXP1 */
-	unsigned	tx_rpxm  :2 ;	/* byte offset */
-	unsigned	tx_xdone :1 ;	/* give up token */
-	unsigned	tx_nfcs  :1 ;	/* no frame check sequence */
-	unsigned	tx_xmtabt:1 ;	/* transmit abort */
-	unsigned	tx_res	 :8 ;	/* reserved 	 (bit 16..23) */
-	unsigned	tx_length:16 ;	/* frame length lower/upper byte */
+	unsigned int	tx_more	 :1 ;	/* more frame in chain */
+	unsigned int	tx_pat1  :2 ;	/* must be TXP1 */
+	unsigned int	tx_rpxm  :2 ;	/* byte offset */
+	unsigned int	tx_xdone :1 ;	/* give up token */
+	unsigned int	tx_nfcs  :1 ;	/* no frame check sequence */
+	unsigned int	tx_xmtabt:1 ;	/* transmit abort */
+	unsigned int	tx_res	 :8 ;	/* reserved 	 (bit 16..23) */
+	unsigned int	tx_length:16 ;	/* frame length lower/upper byte */
 #endif
 	} t ;
 	long	i ;
@@ -202,13 +202,13 @@ union tx_descr {
 union tx_pointer {
 	struct t {
 #ifdef	LITTLE_ENDIAN
-	unsigned	tp_pointer:16 ;	/* pointer to tx_descr (low/high) */
-	unsigned	tp_res	  :8 ;	/* reserved 	 (bit 16..23) */
-	unsigned	tp_pattern:8 ;	/* fixed pattern (bit 24..31) */
+	unsigned int	tp_pointer:16 ;	/* pointer to tx_descr (low/high) */
+	unsigned int	tp_res	  :8 ;	/* reserved 	 (bit 16..23) */
+	unsigned int	tp_pattern:8 ;	/* fixed pattern (bit 24..31) */
 #else
-	unsigned	tp_pattern:8 ;	/* fixed pattern (bit 24..31) */
-	unsigned	tp_res	  :8 ;	/* reserved 	 (bit 16..23) */
-	unsigned	tp_pointer:16 ;	/* pointer to tx_descr (low/high) */
+	unsigned int	tp_pattern:8 ;	/* fixed pattern (bit 24..31) */
+	unsigned int	tp_res	  :8 ;	/* reserved 	 (bit 16..23) */
+	unsigned int	tp_pointer:16 ;	/* pointer to tx_descr (low/high) */
 #endif
 	} t ;
 	long	i ;
diff --git a/drivers/net/fddi/skfp/smt.c b/drivers/net/fddi/skfp/smt.c
index 08d9432..9edada8 100644
--- a/drivers/net/fddi/skfp/smt.c
+++ b/drivers/net/fddi/skfp/smt.c
@@ -900,7 +900,7 @@ static void smt_send_rdf(struct s_smc *smc, SMbuf *rej, int fc, int reason,
 	rdf->version.v_pad2 = 0 ;
 
 	/* set P13 */
-	if ((unsigned) frame_len <= SMT_MAX_INFO_LEN - sizeof(*rdf) +
+	if ((unsigned int) frame_len <= SMT_MAX_INFO_LEN - sizeof(*rdf) +
 		2*sizeof(struct smt_header))
 		len = frame_len ;
 	else
diff --git a/drivers/net/fddi/skfp/srf.c b/drivers/net/fddi/skfp/srf.c
index f6f7baf..cc27dea 100644
--- a/drivers/net/fddi/skfp/srf.c
+++ b/drivers/net/fddi/skfp/srf.c
@@ -73,7 +73,7 @@ void smt_init_evc(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
 	const struct evc_init 	*init ;
-	int			i ;
+	unsigned int		i ;
 	int			index ;
 	int			offset ;
 
@@ -84,7 +84,7 @@ void smt_init_evc(struct s_smc *smc)
 	evc = smc->evcs ;
 	init = evc_inits ;
 
-	for (i = 0 ; (unsigned) i < MAX_INIT_EVC ; i++) {
+	for (i = 0 ; i < MAX_INIT_EVC ; i++) {
 		for (index = 0 ; index < init->n ; index++) {
 			evc->evc_code = init->code ;
 			evc->evc_para = init->para ;
@@ -98,7 +98,7 @@ void smt_init_evc(struct s_smc *smc)
 		init++ ;
 	}
 
-	if ((unsigned) (evc - smc->evcs) > MAX_EVCS) {
+	if ((unsigned int) (evc - smc->evcs) > MAX_EVCS) {
 		SMT_PANIC(smc,SMT_E0127, SMT_E0127_MSG) ;
 	}
 
@@ -139,7 +139,7 @@ void smt_init_evc(struct s_smc *smc)
 		offset++ ;
 	}
 #ifdef	DEBUG
-	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
+	for (i = 0, evc = smc->evcs ; i < MAX_EVCS ; i++, evc++) {
 		if (SMT_IS_CONDITION(evc->evc_code)) {
 			if (!evc->evc_cond_state) {
 				SMT_PANIC(smc,SMT_E0128, SMT_E0128_MSG) ;
@@ -160,10 +160,10 @@ void smt_init_evc(struct s_smc *smc)
 
 static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index)
 {
-	int			i ;
+	unsigned int		i ;
 	struct s_srf_evc	*evc ;
 
-	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
+	for (i = 0, evc = smc->evcs ; i < MAX_EVCS ; i++, evc++) {
 		if (evc->evc_code == code && evc->evc_index == index)
 			return evc;
 	}
@@ -335,9 +335,9 @@ void smt_srf_event(struct s_smc *smc, int code, int index, int cond)
 static void clear_all_rep(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
-	int			i ;
+	unsigned int		i ;
 
-	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
+	for (i = 0, evc = smc->evcs ; i < MAX_EVCS ; i++, evc++) {
 		evc->evc_rep_required = FALSE ;
 		if (SMT_IS_CONDITION(evc->evc_code))
 			*evc->evc_cond_state = FALSE ;
@@ -348,10 +348,10 @@ static void clear_all_rep(struct s_smc *smc)
 static void clear_reported(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
-	int			i ;
+	unsigned int		i ;
 
 	smc->srf.any_report = FALSE ;
-	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
+	for (i = 0, evc = smc->evcs ; i < MAX_EVCS ; i++, evc++) {
 		if (SMT_IS_CONDITION(evc->evc_code)) {
 			if (*evc->evc_cond_state == FALSE)
 				evc->evc_rep_required = FALSE ;
@@ -375,7 +375,7 @@ static void smt_send_srf(struct s_smc *smc)
 	struct s_srf_evc	*evc ;
 	SK_LOC_DECL(struct s_pcon,pcon) ;
 	SMbuf			*mb ;
-	int			i ;
+	unsigned int		i ;
 
 	static const struct fddi_addr SMT_SRF_DA = {
 		{ 0x80, 0x01, 0x43, 0x00, 0x80, 0x08 }
@@ -405,7 +405,7 @@ static void smt_send_srf(struct s_smc *smc)
 	smt_add_para(smc,&pcon,(u_short) SMT_P1033,0,0) ;
 	smt_add_para(smc,&pcon,(u_short) SMT_P1034,0,0) ;
 
-	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
+	for (i = 0, evc = smc->evcs ; i < MAX_EVCS ; i++, evc++) {
 		if (evc->evc_rep_required) {
 			smt_add_para(smc,&pcon,evc->evc_para,
 				(int)evc->evc_index,0) ;
-- 
1.8.0
