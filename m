From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert sk fddi driver to ANSI C
Date: Thu, 17 Jun 2004 14:53:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617145327.3249f4dc@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sparse does not handle K&R at all, and I think I saw Linus saying that
he has no intention of adding it to sparse while ago. So here is a blob
of patch to convert drivers/net/skfp/* from K&R to ANSI-C. Compile
tested with "make allmodconfig" on x86, as I obviously don't have the
HW.  

Mika

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/skfp/cfm.c b/drivers/net/skfp/cfm.c
--- a/drivers/net/skfp/cfm.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/cfm.c	2004-06-17 14:49:49 -07:00
@@ -96,14 +96,13 @@
 /*
  * function declarations
  */
-static void cfm_fsm() ;
+static void cfm_fsm(struct s_smc *smc, int cmd);
 
 /*
 	init CFM state machine
 	clear all CFM vars and flags
 */
-void cfm_init(smc)
-struct s_smc *smc ;
+void cfm_init(struct s_smc *smc)
 {
 	smc->mib.fddiSMTCF_State = ACTIONS(SC0_ISOLATED) ;
 	smc->r.rm_join = 0 ;
@@ -118,9 +117,7 @@
 #define THRU_ENABLED(smc)	(smc->y[PA].pc_mode != PM_TREE && \
 				 smc->y[PB].pc_mode != PM_TREE)
 /* Selection criteria for the ports */
-static void	selection_criteria (smc,phy)
-struct s_smc	*smc ;
-struct s_phy	*phy ;
+static void selection_criteria (struct s_smc *smc, struct s_phy *phy)
 {
 
 	switch (phy->mib->fddiPORTMy_Type) {
@@ -146,8 +143,7 @@
 
 }
 
-void	all_selection_criteria (smc)
-struct s_smc *smc ;
+void all_selection_criteria(struct s_smc *smc)
 {
 	struct s_phy	*phy ;
 	int		p ;
@@ -158,9 +154,7 @@
 	}
 }
 
-static void	cem_priv_state (smc, event)
-struct s_smc *smc ;
-int event ;
+static void cem_priv_state(struct s_smc *smc, int event)
 /* State machine for private PORT states: used to optimize dual homing */
 {
 	int	np;	/* Number of the port */
@@ -216,9 +210,7 @@
 		process event
 	until SM is stable
 */
-void cfm(smc,event)
-struct s_smc *smc ;
-int event ;
+void cfm(struct s_smc *smc, int event)
 {
 	int	state ;		/* remember last state */
 	int	cond ;
@@ -290,9 +282,7 @@
 	process CFM event
 */
 /*ARGSUSED1*/
-static void cfm_fsm(smc,cmd)
-struct s_smc *smc ;
-int cmd ;
+static void cfm_fsm(struct s_smc *smc, int cmd)
 {
 	switch(smc->mib.fddiSMTCF_State) {
 	case ACTIONS(SC0_ISOLATED) :
@@ -550,8 +540,7 @@
  *	return :
  *		PA or PB
  */
-int cfm_get_mac_input(smc)
-struct s_smc *smc ;
+int cfm_get_mac_input(struct s_smc *smc)
 {
 	return((smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
 		smc->mib.fddiSMTCF_State == SC5_THRU_B) ? PB : PA) ;
@@ -562,8 +551,7 @@
  *	return :
  *		PA or PB
  */
-int cfm_get_mac_output(smc)
-struct s_smc *smc ;
+int cfm_get_mac_output(struct s_smc *smc)
 {
 	return((smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
 		smc->mib.fddiSMTCF_State == SC4_THRU_A) ? PB : PA) ;
@@ -603,10 +591,7 @@
 	0,0,	0,RES_MAC,	0,INDEX_MAC,		0,PATH_ISO,
 } ;
 
-int cem_build_path(smc,to,path_index)
-struct s_smc *smc ;
-char *to ;
-int path_index ;
+int cem_build_path(struct s_smc *smc, char *to, int path_index)
 {
 	char	*path ;
 	int	len ;
diff -Nru a/drivers/net/skfp/drvfbi.c b/drivers/net/skfp/drvfbi.c
--- a/drivers/net/skfp/drvfbi.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/drvfbi.c	2004-06-17 14:49:49 -07:00
@@ -100,14 +100,13 @@
 #endif	/* MULT_OEM */
 
 /* Prototypes of external functions */
-extern void hwt_restart() ;
 #ifdef AIX
 extern int AIX_vpdReadByte() ;
 #endif
 
 
 /* Prototypes of local functions. */
-void smt_stop_watchdog() ;
+void smt_stop_watchdog(struct s_smc *smc);
 
 #ifdef MCA
 static int read_card_id() ;
@@ -129,8 +128,7 @@
 /*
  * FDDI card reset
  */
-static void card_start(smc)
-struct s_smc *smc ;
+static void card_start(struct s_smc *smc)
 {
 	int i ;
 #ifdef	PCI
@@ -250,8 +248,7 @@
 	GET_PAGE(0) ;		/* necessary for BOOT */
 }
 
-void card_stop(smc)
-struct s_smc *smc ;
+void card_stop(struct s_smc *smc)
 {
 	smt_stop_watchdog(smc) ;
 	smc->hw.mac_ring_is_up = 0 ;		/* ring down */
@@ -282,14 +279,11 @@
 }
 /*--------------------------- ISR handling ----------------------------------*/
 
-#ifndef PCI
-void mac1_irq(smc,stu, stl)
-struct s_smc *smc ;
-u_short stu;
-u_short stl;
+void mac1_irq(struct s_smc *smc, u_short stu, u_short stl)
 {
 	int	restart_tx = 0 ;
 again:
+#ifndef PCI
 #ifndef ISA
 /*
  * FORMAC+ bug modified the queue pointer if many read/write accesses happens!?
@@ -344,14 +338,6 @@
 }
 #else	/* PCI */
 
-void mac1_irq(smc,stu, stl)
-struct s_smc *smc ;
-u_short stu;
-u_short stl;
-{
-	int	restart_tx = 0 ;
-again:
-
 	/*
 	 * parity error: note encoding error is not possible in tag mode
 	 */
@@ -396,8 +382,7 @@
  * interrupt source= plc1
  * this function is called in nwfbisr.asm
  */
-void plc1_irq(smc)
-struct s_smc *smc ;
+void plc1_irq(struct s_smc *smc)
 {
 	u_short	st = inpw(PLC(PB,PL_INTR_EVENT)) ;
 
@@ -412,8 +397,7 @@
  * interrupt source= plc2
  * this function is called in nwfbisr.asm
  */
-void plc2_irq(smc)
-struct s_smc *smc ;
+void plc2_irq(struct s_smc *smc)
 {
 	u_short	st = inpw(PLC(PA,PL_INTR_EVENT)) ;
 
@@ -428,8 +412,7 @@
 /*
  * interrupt source= timer
  */
-void timer_irq(smc)
-struct s_smc *smc ;
+void timer_irq(struct s_smc *smc)
 {
 	hwt_restart(smc);
 	smc->hw.t_stop = smc->hw.t_start;
@@ -439,8 +422,7 @@
 /*
  * return S-port (PA or PB)
  */
-int pcm_get_s_port(smc)
-struct s_smc *smc ;
+int pcm_get_s_port(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;
 	return(PS) ;
@@ -457,9 +439,7 @@
 #define STATION_LABEL_PMD_OFFSET	6
 #define STATION_LABEL_PORT_OFFSET	7
 
-void read_address(smc,mac_addr)
-struct s_smc *smc ;
-u_char *mac_addr ;
+void read_address(struct s_smc *smc, u_char *mac_addr)
 {
 	char ConnectorType ;
 	char PmdType ;
@@ -528,9 +508,7 @@
 /*
  * FDDI card soft reset
  */
-void init_board(smc,mac_addr)
-struct s_smc *smc ;
-u_char *mac_addr ;
+void init_board(struct s_smc *smc, u_char *mac_addr)
 {
 	card_start(smc) ;
 	read_address(smc,mac_addr) ;
@@ -559,9 +537,7 @@
 /*
  * insert or deinsert optical bypass (called by ECM)
  */
-void sm_pm_bypass_req(smc,mode)
-struct s_smc *smc ;
-int mode;
+void sm_pm_bypass_req(struct s_smc *smc, int mode)
 {
 #if	(defined(ISA) || defined(EISA))
 	int csra_v ;
@@ -614,8 +590,7 @@
 /*
  * check if bypass connected
  */
-int sm_pm_bypass_present(smc)
-struct s_smc *smc ;
+int sm_pm_bypass_present(struct s_smc *smc)
 {
 #ifndef	PCI
 	return(	(inpw(CSR_A) & CS_BYSTAT) ? FALSE : TRUE ) ;
@@ -624,9 +599,7 @@
 #endif
 }
 
-void plc_clear_irq(smc,p)
-struct s_smc *smc ;
-int p ;
+void plc_clear_irq(struct s_smc *smc, int p)
 {
 	SK_UNUSED(p) ;
 
@@ -658,9 +631,7 @@
  *	LED_Y_OFF	just switch yellow LED off
  *	LED_Y_ON	just switch yello LED on
  */
-void led_indication(smc,led_event)
-struct s_smc	*smc ;
-int		led_event;
+void led_indication(struct s_smc *smc, int led_event)
 {
 	/* use smc->hw.mac_ring_is_up == TRUE 
 	 * as indication for Ring Operational
@@ -754,10 +725,7 @@
 }
 
 
-void pcm_state_change(smc,plc,p_state)
-struct s_smc *smc;
-int plc;
-int p_state;
+void pcm_state_change(struct s_smc *smc, int plc, int p_state)
 {
 	/*
 	 * the current implementation of pcm_state_change() in the driver
@@ -770,9 +738,7 @@
 }
 
 
-void rmt_indication(smc,i)
-struct s_smc *smc ;
-int i;
+void rmt_indication(struct s_smc *smc, int i)
 {
 	/* Call a driver special function if defined */
 	DRV_RMT_INDICATION(smc,i) ;
@@ -784,8 +750,7 @@
 /*
  * llc_recover_tx called by init_tx (fplus.c)
  */
-void llc_recover_tx(smc)
-struct s_smc *smc ;
+void llc_recover_tx(struct s_smc *smc)
 {
 #ifdef	LOAD_GEN
 	extern	int load_gen_flag ;
@@ -805,9 +770,7 @@
 /*
  * init DMA
  */
-void init_dma(smc,dma)
-struct s_smc *smc;
-int	dma;
+void init_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 
@@ -828,9 +791,7 @@
 /*
  * disable DMA
  */
-void dis_dma(smc,dma)
-struct s_smc *smc ;
-int	dma;
+void dis_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 
@@ -854,9 +815,7 @@
 static const int base[8] = { 0x000,0x002,0x004,0x006,0,0x0c4,0x0c8,0x0cc } ;
 static const int page[8] = { 0x087,0x083,0x081,0x082,0,0x08b,0x089,0x08a } ;
 
-void init_dma(smc,dma)
-struct s_smc *smc ;
-int	dma;
+void init_dma(struct s_smc *smc, int dma)
 {
 	/*
 	 * extended mode register
@@ -885,9 +844,7 @@
 
 }
 
-void dis_dma(smc,dma)
-struct s_smc *smc ;
-int	dma;
+void dis_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 
@@ -896,16 +853,13 @@
 #endif	/* EISA */
 
 #ifdef	MCA
-void init_dma(smc,dma)
-struct s_smc *smc;
-int	dma;
+void init_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(dma) ;
 }
-void dis_dma(smc,dma)
-struct s_smc *smc;
-int	dma;
+
+void dis_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(dma) ;
@@ -913,16 +867,13 @@
 #endif
 
 #ifdef	PCI
-void init_dma(smc,dma)
-struct s_smc *smc;
-int	dma;
+void init_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(dma) ;
 }
-void dis_dma(smc,dma)
-struct s_smc *smc;
-int	dma;
+
+void dis_dma(struct s_smc *smc, int dma)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(dma) ;
@@ -930,10 +881,7 @@
 #endif
 
 #ifdef MULT_OEM
-static int is_equal_num(comp1,comp2,num)
-char comp1[] ;
-char comp2[] ;
-int num ;
+static int is_equal_num(char comp1[], char comp2[], int num)
 {
 	int i ;
 
@@ -954,8 +902,7 @@
  *		2	data base empty
  *		3	no active entry	
  */
-int set_oi_id_def(smc)
-struct s_smc *smc ;
+int set_oi_id_def(struct s_smc *smc)
 {
 	int sel_id ;
 	int i ;
@@ -1029,9 +976,7 @@
  *
  ************************/
 #define LONG_CARD_ID(lo, hi)	((((hi) & 0xff) << 8) | ((lo) & 0xff))
-int exist_board(smc,slot)
-struct s_smc *smc ;
-int	slot ;
+int exist_board(struct s_smc *smc, int slot)
 {
 #ifdef MULT_OEM
 	SK_LOC_DECL(u_char,id[2]) ;
@@ -1081,9 +1026,8 @@
  *	number is specified, the function returns zero.
  *
  ************************/
-static int read_card_id(smc,slot)
-struct s_smc *smc ;	/* Do not use. */
-int slot ;
+static int read_card_id(struct s_smc *smc, int slot)
+/* struct s_smc *smc ;	Do not use. */
 {
 	int card_id ;
 
@@ -1126,9 +1070,7 @@
  * END_MANUAL_ENTRY()
  *
  ************************/
-int get_board_para(smc,slot)
-struct s_smc *smc ;
-int slot ;
+int get_board_para(struct s_smc *smc, int slot)
 {
 	int val ;
 	int i ;
@@ -1175,9 +1117,7 @@
 }
 
 /* Enable access to specified MCA slot. */
-static void EnableSlotAccess(smc,slot)
-struct s_smc *smc ;
-int slot ;
+static void EnableSlotAccess(struct s_smc *smc, int slot)
 {
 	SK_UNUSED(slot) ;
 
@@ -1195,8 +1135,7 @@
 }
 
 /* Disable access to MCA slot formerly enabled via EnableSlotAccess(). */
-static void DisableSlotAccess(smc)
-struct s_smc *smc ;
+static void DisableSlotAccess(struct s_smc *smc)
 {
 #ifndef AIX
 	SK_UNUSED(smc) ;
@@ -1245,9 +1184,7 @@
  *	The smc pointer must be valid now.
  *
  ************************/
-int exist_board(smc,slot)
-struct s_smc *smc ;
-int	slot ;
+int exist_board(struct s_smc *smc, int slot)
 {
 	int i ;
 #ifdef MULT_OEM
@@ -1284,9 +1221,7 @@
 }
 
 
-int get_board_para(smc,slot)
-struct s_smc *smc ;
-int	slot ;
+int get_board_para(struct s_smc *smc, int slot)
 {
 	int	i ;
 
@@ -1327,9 +1262,7 @@
 #endif	/* MULT_OEM */
 
 
-int exist_board(smc,port)
-struct s_smc *smc ;
-HW_PTR	port ;
+int exist_board(struct s_smc *smc, HW_PTR port)
 {
 	int	i ;
 #ifdef MULT_OEM
@@ -1400,9 +1333,7 @@
 #endif	/* MULT_OEM */
 }
 
-int get_board_para(smc,slot)
-struct s_smc *smc ;
-int	slot ;
+int get_board_para(struct s_smc *smc, int slot)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(slot) ;
@@ -1412,9 +1343,7 @@
 
 #ifdef PCI
 #ifdef USE_BIOS_FUN
-int exist_board(smc,slot)
-struct s_smc *smc ;
-int	slot ;
+int exist_board(struct s_smc *smc, int slot)
 {
 	u_short dev_id ;
 	u_short ven_id ;
@@ -1452,9 +1381,7 @@
 #endif	/* PCI */
 #endif	/* USE_BIOS_FUNC */
 
-void driver_get_bia(smc, bia_addr)
-struct s_smc *smc ;
-struct fddi_addr *bia_addr ;
+void driver_get_bia(struct s_smc *smc, struct fddi_addr *bia_addr)
 {
 	int i ;
 
@@ -1465,8 +1392,7 @@
 	}
 }
 
-void smt_start_watchdog(smc)
-struct s_smc *smc ;
+void smt_start_watchdog(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;	/* Make LINT happy. */
 
@@ -1481,8 +1407,7 @@
 #endif	/* DEBUG */
 }
 
-void smt_stop_watchdog(smc)
-struct s_smc *smc ;
+void smt_stop_watchdog(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;	/* Make LINT happy. */
 #ifndef	DEBUG
@@ -1497,9 +1422,7 @@
 }
 
 #ifdef	PCI
-static char get_rom_byte(smc,addr)
-struct s_smc *smc ;
-u_short	addr ;
+static char get_rom_byte(struct s_smc *smc, u_short addr)
 {
 	GET_PAGE(addr) ;
 	return (READ_PROM(ADDR(B2_FDP))) ;
@@ -1544,11 +1467,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-int mac_drv_vpd_read(smc,buf,size,image)
-struct s_smc *smc ;
-char *buf ;
-int size ;
-char image ;
+int mac_drv_vpd_read(struct s_smc *smc, char *buf, int size, char image)
 {
 	u_short	ibase ;
 	u_short pci_base ;
@@ -1597,16 +1516,14 @@
 	return(len) ;
 }
 
-void mac_drv_pci_fix(smc,fix_value)
-struct s_smc *smc ;
-u_long fix_value ;
+void mac_drv_pci_fix(struct s_smc *smc, u_long fix_value)
 {
 	smc->hw.pci_fix_value = fix_value ;
 }
 
-void mac_do_pci_fix(smc)
-struct s_smc *smc ;
+void mac_do_pci_fix(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;
 }
 #endif	/* PCI */
+
diff -Nru a/drivers/net/skfp/ecm.c b/drivers/net/skfp/ecm.c
--- a/drivers/net/skfp/ecm.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/ecm.c	2004-06-17 14:49:49 -07:00
@@ -94,17 +94,16 @@
  * function declarations
  */
 
-static void ecm_fsm() ;
-static void start_ecm_timer() ;
-static void stop_ecm_timer() ;
-static void prop_actions() ;
+static void ecm_fsm(struct s_smc *smc, int cmd);
+static void start_ecm_timer(struct s_smc *smc, u_long value, int event);
+static void stop_ecm_timer(struct s_smc *smc);
+static void prop_actions(struct s_smc *smc);
 
 /*
 	init ECM state machine
 	clear all ECM vars and flags
 */
-void ecm_init(smc)
-struct s_smc *smc ;
+void ecm_init(struct s_smc *smc)
 {
 	smc->e.path_test = PT_PASSED ;
 	smc->e.trace_prop = 0 ;
@@ -122,9 +121,7 @@
 		process event
 	until SM is stable
 */
-void ecm(smc,event)
-struct s_smc *smc ;
-int event ;
+void ecm(struct s_smc *smc, int event)
 {
 	int	state ;
 
@@ -143,9 +140,7 @@
 /*
 	process ECM event
 */
-static void ecm_fsm(smc,cmd)
-struct s_smc *smc ;
-int cmd ;
+static void ecm_fsm(struct s_smc *smc, int cmd)
 {
 	int ls_a ;			/* current line state PHY A */
 	int ls_b ;			/* current line state PHY B */
@@ -429,8 +424,7 @@
 /*
  * trace propagation actions for SAS & DAS
  */
-static void prop_actions(smc)
-struct s_smc *smc ;
+static void prop_actions(struct s_smc *smc)
 {
 	int	port_in = 0 ;
 	int	port_out = 0 ;
@@ -480,8 +474,7 @@
 /*
  * trace propagation actions for Concentrator
  */
-static void prop_actions(smc)
-struct s_smc *smc ;
+static void prop_actions(struct s_smc *smc)
 {
 	int	initiator ;
 	int	upstream ;
@@ -527,10 +520,7 @@
  * SMT timer interface
  *	start ECM timer
  */
-static void start_ecm_timer(smc,value,event)
-struct s_smc *smc ;
-u_long value;
-int event ;
+static void start_ecm_timer(struct s_smc *smc, u_long value, int event)
 {
 	smt_timer_start(smc,&smc->e.ecm_timer,value,EV_TOKEN(EVENT_ECM,event));
 }
@@ -539,8 +529,7 @@
  * SMT timer interface
  *	stop ECM timer
  */
-static void stop_ecm_timer(smc)
-struct s_smc *smc ;
+static void stop_ecm_timer(struct s_smc *smc)
 {
 	if (smc->e.ecm_timer.tm_active)
 		smt_timer_stop(smc,&smc->e.ecm_timer) ;
diff -Nru a/drivers/net/skfp/ess.c b/drivers/net/skfp/ess.c
--- a/drivers/net/skfp/ess.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/ess.c	2004-06-17 14:49:49 -07:00
@@ -80,8 +80,11 @@
 	-------------------------------------------------------------
 */
 
-static	void	ess_send_response(),		ess_config_fifo(),
-		ess_send_alc_req(),		ess_send_frame() ;
+static void ess_send_response(struct s_smc *smc, struct smt_header *sm,
+			      int sba_cmd);
+static void ess_config_fifo(struct s_smc *smc);
+static void ess_send_alc_req(struct s_smc *smc);
+static void ess_send_frame(struct s_smc *smc, SMbuf *mb);
 
 /*
 	-------------------------------------------------------------
@@ -89,26 +92,17 @@
 	-------------------------------------------------------------
 */
 
-extern	void	*sm_to_para() ;
-
-extern	void	smt_send_frame(),	smt_free_mbuf(),
-		set_formac_tsync(),	formac_reinit_tx() ;
-
-extern	int	smt_check_para() ;
-
-extern	SMbuf	*smt_get_mbuf(),	*smt_build_frame() ;
-
-extern	u_long	smt_get_tid() ;
-
 /*
 	-------------------------------------------------------------
 	PUBLIC FUNCTIONS:
 	-------------------------------------------------------------
 */
 
-	void	ess_timer_poll(),		ess_para_change() ;
-
-	int	ess_raf_received_pack(),	process_bw_alloc() ;
+void ess_timer_poll(struct s_smc *smc);
+void ess_para_change(struct s_smc *smc);
+int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
+			  int fs);
+int process_bw_alloc(struct s_smc *smc, long int payload, long int overhead);
 
 
 /*
@@ -120,11 +114,8 @@
 /*
  * evaluate the RAF frame
  */
-int ess_raf_received_pack(smc,mb,sm,fs)
-struct s_smc *smc ;
-SMbuf *mb ;
-struct smt_header *sm ;
-int fs ;
+int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
+			  int fs)
 {
 	void			*p ;		/* universal pointer */
 	struct smt_p_0016	*cmd ;		/* para: command for the ESS */
@@ -384,10 +375,7 @@
  * determines the synchronous bandwidth, set the TSYNC register and the
  * mib variables SBAPayload, SBAOverhead and fddiMACT-NEG.
  */
-int process_bw_alloc(smc,payload,overhead)
-struct s_smc *smc ;
-long payload ;
-long overhead ;
+int process_bw_alloc(struct s_smc *smc, long int payload, long int overhead)
 {
 	/*
 	 * determine the synchronous bandwidth (sync_bw) in bytes per T-NEG,
@@ -483,10 +471,8 @@
 	return(TRUE) ;
 }
 
-static void ess_send_response(smc,sm,sba_cmd)
-struct s_smc *smc ;
-struct smt_header *sm ;
-int sba_cmd ;
+static void ess_send_response(struct s_smc *smc, struct smt_header *sm,
+			      int sba_cmd)
 {
 	struct smt_sba_chg	*chg ;
 	SMbuf			*mb ;
@@ -550,9 +536,7 @@
 	ess_send_frame(smc,mb) ;
 }
 
-
-void ess_timer_poll(smc)
-struct s_smc *smc ;
+void ess_timer_poll(struct s_smc *smc)
 {
 	if (!smc->ess.raf_act_timer_poll)
 		return ;
@@ -566,8 +550,7 @@
 	}
 }
 
-static void ess_send_alc_req(smc)
-struct s_smc *smc ;
+static void ess_send_alc_req(struct s_smc *smc)
 {
 	struct smt_sba_alc_req *req ;
 	SMbuf	*mb ;
@@ -675,9 +658,7 @@
 	ess_send_frame(smc,mb) ;
 }
 
-static void ess_send_frame(smc,mb)
-struct s_smc *smc ;
-SMbuf *mb ;
+static void ess_send_frame(struct s_smc *smc, SMbuf *mb)
 {
 	/*
 	 * check if the frame must be send to the own ESS
@@ -703,15 +684,13 @@
 	}
 }
 
-void ess_para_change(smc)
-struct s_smc *smc ;
+void ess_para_change(struct s_smc *smc)
 {
 	(void)process_bw_alloc(smc,(long)smc->mib.a[PATH0].fddiPATHSbaPayload,
 		(long)smc->mib.a[PATH0].fddiPATHSbaOverhead) ;
 }
 
-static void ess_config_fifo(smc)
-struct s_smc *smc ;
+static void ess_config_fifo(struct s_smc *smc)
 {
 	/*
 	 * if nothing to do exit 
@@ -738,3 +717,4 @@
 #endif /* ESS */
 
 #endif	/* no SLIM_SMT */
+
diff -Nru a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
--- a/drivers/net/skfp/fplustm.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/fplustm.c	2004-06-17 14:49:49 -07:00
@@ -43,10 +43,10 @@
 /*
  * prototypes for static function
  */
-static void build_claim_beacon() ;
-static int init_mac() ;
-static void rtm_init() ;
-static void smt_split_up_fifo() ;
+static void build_claim_beacon(struct s_smc *smc, u_long t_request);
+static int init_mac(struct s_smc *smc, int all);
+static void rtm_init(struct s_smc *smc);
+static void smt_split_up_fifo(struct s_smc *smc);
 
 #if (!defined(NO_SMT_PANIC) || defined(DEBUG))
 static	char write_mdr_warning [] = "E350 write_mdr() FM_SNPPND is set\n";
@@ -107,8 +107,7 @@
 			FM_SLOCLM | FM_SHICLM | FM_SMYCLM | FM_SCLM ;
 
 
-static u_long mac_get_tneg(smc)
-struct s_smc *smc ;
+static u_long mac_get_tneg(struct s_smc *smc)
 {
 	u_long	tneg ;
 
@@ -117,8 +116,7 @@
 		0xffe00000L)) ;
 }
 
-void mac_update_counter(smc)
-struct s_smc *smc ;
+void mac_update_counter(struct s_smc *smc)
 {
 	smc->mib.m[MAC0].fddiMACFrame_Ct =
 		(smc->mib.m[MAC0].fddiMACFrame_Ct & 0xffff0000L)
@@ -143,9 +141,7 @@
 /*
  * write long value into buffer memory over memory data register (MDR),
  */
-void	write_mdr(smc,val)
-struct s_smc *smc ;
-u_long val;
+void	write_mdr(struct s_smc *smc, u_long val)
 {
 	CHECK_NPP() ;
 	MDRW(val) ;
@@ -154,9 +150,7 @@
 /*
  * read long value from buffer memory over memory data register (MDR),
  */
-u_long read_mdr(smc,addr)
-struct s_smc *smc ;
-unsigned int addr;
+u_long read_mdr(struct s_smc *smc, unsigned int addr)
 {
 	long p ;
 	CHECK_NPP() ;
@@ -173,8 +167,7 @@
 /*
  * clear buffer memory
  */
-static void init_ram(smc)
-struct s_smc *smc ;
+static void init_ram(struct s_smc *smc)
 {
 	u_short i ;
 
@@ -193,8 +186,7 @@
 /*
  * set receive FIFO pointer
  */
-static void set_recvptr(smc)
-struct s_smc *smc ;
+static void set_recvptr(struct s_smc *smc)
 {
 	/*
 	 * initialize the pointer for receive queue 1
@@ -224,8 +216,7 @@
 /*
  * set transmit FIFO pointer
  */
-static void set_txptr(smc)
-struct s_smc *smc ;
+static void set_txptr(struct s_smc *smc)
 {
 	outpw(FM_A(FM_CMDREG2),FM_IRSTQ) ;	/* reset transmit queues */
 
@@ -257,8 +248,7 @@
 /*
  * init memory buffer management registers
  */
-static void init_rbc(smc)
-struct s_smc *smc ;
+static void init_rbc(struct s_smc *smc)
 {
 	u_short	rbc_ram_addr ;
 
@@ -279,8 +269,7 @@
 /*
  * init rx pointer
  */
-static void init_rx(smc)
-struct s_smc *smc ;
+static void init_rx(struct s_smc *smc)
 {
 	struct s_smt_rx_queue	*queue ;
 
@@ -302,9 +291,7 @@
 /*
  * set the TSYNC register of the FORMAC to regulate synchronous transmission
  */
-void set_formac_tsync(smc,sync_bw)
-struct s_smc *smc ;
-long sync_bw ;
+void set_formac_tsync(struct s_smc *smc, long sync_bw)
 {
 	outpw(FM_A(FM_TSYNC),(unsigned int) (((-sync_bw) >> 5) & 0xffff) ) ;
 }
@@ -312,8 +299,7 @@
 /*
  * init all tx data structures
  */
-static void init_tx(smc)
-struct s_smc *smc ;
+static void init_tx(struct s_smc *smc)
 {
 	struct s_smt_tx_queue	*queue ;
 
@@ -339,8 +325,7 @@
 	llc_recover_tx(smc) ;
 }
 
-static void mac_counter_init(smc)
-struct s_smc *smc ;
+static void mac_counter_init(struct s_smc *smc)
 {
 	int i ;
 	u_long *ec ;
@@ -363,8 +348,7 @@
 /*
  * set FORMAC address, and t_request
  */
-static	void set_formac_addr(smc)
-struct s_smc *smc ;
+static	void set_formac_addr(struct s_smc *smc)
 {
 	long	t_requ = smc->mib.m[MAC0].fddiMACT_Req ;
 
@@ -390,9 +374,7 @@
 	outpw(FM_A(FM_TREQ0),(unsigned)t_requ) ;
 }
 
-static void set_int(p,l)
-char *p;
-int l;
+static void set_int(char *p, int l)
 {
 	p[0] = (char)(l >> 24) ;
 	p[1] = (char)(l >> 16) ;
@@ -408,12 +390,12 @@
  * else
  *	append 'end of chain' pointer
  */
-static void copy_tx_mac(smc,td,mac,off,len)
-struct s_smc *smc ;
-u_long td;		/* transmit descriptor */
-struct fddi_mac *mac;	/* mac frame pointer */
-unsigned off;		/* start address within buffer memory */
-int len ;		/* lenght of the frame including the FC */
+static void copy_tx_mac(struct s_smc *smc, u_long td, struct fddi_mac *mac,
+			unsigned off, int len)
+/* u_long td;		 transmit descriptor */
+/* struct fddi_mac *mac; mac frame pointer */
+/* unsigned off;	 start address within buffer memory */
+/* int len ;		 lenght of the frame including the FC */
 {
 	int	i ;
 	u_int	*p ;
@@ -457,8 +439,7 @@
 
 	END_MANUAL_ENTRY
  */
-static void directed_beacon(smc)
-struct s_smc *smc ;
+static void directed_beacon(struct s_smc *smc)
 {
 	SK_LOC_DECL(u_int,a[2]) ;
 
@@ -487,9 +468,7 @@
 		special frame packets end with a pointer to their own
 		descriptor, and the MORE bit is set in the descriptor
 */
-static void build_claim_beacon(smc,t_request)
-struct s_smc *smc ;
-u_long t_request;
+static void build_claim_beacon(struct s_smc *smc, u_long t_request)
 {
 	u_int	td ;
 	int	len ;
@@ -550,8 +529,7 @@
 	outpw(FM_A(FM_RPXSF),0) ;
 }
 
-void formac_rcv_restart(smc)
-struct s_smc *smc ;
+void formac_rcv_restart(struct s_smc *smc)
 {
 	/* enable receive function */
 	SETMASK(FM_A(FM_MDREG1),smc->hw.fp.rx_mode,FM_ADDRX) ;
@@ -559,15 +537,13 @@
 	outpw(FM_A(FM_CMDREG1),FM_ICLLR) ;	/* clear receive lock */
 }
 
-void formac_tx_restart(smc)
-struct s_smc *smc ;
+void formac_tx_restart(struct s_smc *smc)
 {
 	outpw(FM_A(FM_CMDREG1),FM_ICLLS) ;	/* clear s-frame lock */
 	outpw(FM_A(FM_CMDREG1),FM_ICLLA0) ;	/* clear a-frame lock */
 }
 
-static void enable_formac(smc)
-struct s_smc *smc ;
+static void enable_formac(struct s_smc *smc)
 {
 	/* set formac IMSK : 0 enables irq */
 	outpw(FM_A(FM_IMSK1U),~mac_imsk1u) ;
@@ -607,9 +583,8 @@
 
 	END_MANUAL_ENTRY
  */
-void enable_tx_irq(smc, queue)
-struct s_smc *smc ;
-u_short	queue ;		/* 0 = synchronous queue, 1 = asynchronous queue 0 */
+void enable_tx_irq(struct s_smc *smc, u_short queue)
+/* u_short queue; 0 = synchronous queue, 1 = asynchronous queue 0 */
 {
 	u_short	imask ;
 
@@ -643,9 +618,8 @@
 
 	END_MANUAL_ENTRY
  */
-void disable_tx_irq(smc, queue)
-struct s_smc *smc ;
-u_short	queue ;		/* 0 = synchronous queue, 1 = asynchronous queue 0 */
+void disable_tx_irq(struct s_smc *smc, u_short queue)
+/* u_short queue; 0 = synchronous queue, 1 = asynchronous queue 0 */
 {
 	u_short	imask ;
 
@@ -660,8 +634,7 @@
 }
 #endif
 
-static void disable_formac(smc)
-struct s_smc *smc ;
+static void disable_formac(struct s_smc *smc)
 {
 	/* clear formac IMSK : 1 disables irq */
 	outpw(FM_A(FM_IMSK1U),MW) ;
@@ -673,9 +646,7 @@
 }
 
 
-static void mac_ring_up(smc,up)
-struct s_smc *smc ;
-int up;
+static void mac_ring_up(struct s_smc *smc, int up)
 {
 	if (up) {
 		formac_rcv_restart(smc) ;	/* enable receive function */
@@ -702,10 +673,7 @@
  * mac2_irq:	status bits for the receive queue 1, and ring status
  * 		ring status indication bits
  */
-void mac2_irq(smc,code_s2u,code_s2l)
-struct s_smc *smc ;
-u_short code_s2u ;
-u_short code_s2l ;
+void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l)
 {
 	u_short	change_s2l ;
 	u_short	change_s2u ;
@@ -831,10 +799,7 @@
 /*
  * mac3_irq:	receive queue 2 bits and address detection bits
  */
-void mac3_irq(smc,code_s3u,code_s3l)
-struct s_smc *smc ;
-u_short code_s3u ;
-u_short code_s3l ;
+void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l)
 {
 	UNUSED(code_s3l) ;
 
@@ -857,8 +822,7 @@
 /*
  * take formac offline
  */
-static void formac_offline(smc)
-struct s_smc *smc ;
+static void formac_offline(struct s_smc *smc)
 {
 	outpw(FM_A(FM_CMDREG2),FM_IACTR) ;/* abort current transmit activity */
 
@@ -876,8 +840,7 @@
 /*
  * bring formac online
  */
-static void formac_online(smc)
-struct s_smc *smc ;
+static void formac_online(struct s_smc *smc)
 {
 	enable_formac(smc) ;
 	SETMASK(FM_A(FM_MDREG1),FM_MONLINE | FM_SELRA | MDR1INIT |
@@ -887,8 +850,7 @@
 /*
  * FORMAC+ full init. (tx, rx, timer, counter, claim & beacon)
  */
-int init_fplus(smc)
-struct s_smc *smc ;
+int init_fplus(struct s_smc *smc)
 {
 	smc->hw.fp.nsa_mode = FM_MRNNSAFNMA ;
 	smc->hw.fp.rx_mode = FM_MDAMA ;
@@ -926,9 +888,7 @@
 	/* enable_formac(smc) ; */
 }
 
-static int init_mac(smc,all)
-struct s_smc *smc ;
-int all ;
+static int init_mac(struct s_smc *smc, int all)
 {
 	u_short	t_max,x ;
 	u_long	time=0 ;
@@ -1033,9 +993,7 @@
 /*
  * called by CFM
  */
-void config_mux(smc,mux)
-struct s_smc *smc ;
-int mux;
+void config_mux(struct s_smc *smc, int mux)
 {
 	plc_config_mux(smc,mux) ;
 
@@ -1049,8 +1007,7 @@
  * the interrupt must not be permanently enabled
  * RMT calls this function periodically (timer driven polling)
  */
-void sm_mac_check_beacon_claim(smc)
-struct s_smc *smc ;
+void sm_mac_check_beacon_claim(struct s_smc *smc)
 {
 	/* set formac IMSK : 0 enables irq */
 	outpw(FM_A(FM_IMSK2U),~(mac_imsk2u | mac_beacon_imsk2u)) ;
@@ -1063,9 +1020,7 @@
 /*
  * control ODL output
  */
-void sm_pm_control(smc,mode)
-struct s_smc *smc ;
-int mode;
+void sm_pm_control(struct s_smc *smc, int mode)
 {
 	SK_UNUSED(smc) ;
 
@@ -1084,9 +1039,7 @@
 /*
  * control MAC layer	(called by RMT)
  */
-void sm_ma_control(smc,mode)
-struct s_smc *smc ;
-int mode;
+void sm_ma_control(struct s_smc *smc, int mode)
 {
 	switch(mode) {
 	case MA_OFFLINE :
@@ -1110,8 +1063,7 @@
 	}
 }
 
-int sm_mac_get_tx_state(smc)
-struct s_smc *smc ;
+int sm_mac_get_tx_state(struct s_smc *smc)
 {
 	return((inpw(FM_A(FM_STMCHN))>>4)&7) ;
 }
@@ -1120,12 +1072,10 @@
  * multicast functions
  */
 
-static struct s_fpmc	*mac_get_mc_table(smc,user,own,del,can)
-struct s_smc *smc ;
-struct fddi_addr *user ;
-struct fddi_addr *own ;
-int del ;
-int can ;
+static struct s_fpmc* mac_get_mc_table(struct s_smc *smc,
+				       struct fddi_addr *user,
+				       struct fddi_addr *own,
+				       int del, int can)
 {
 	struct s_fpmc	*tb ;
 	struct s_fpmc	*slot ;
@@ -1166,8 +1116,7 @@
 
 	END_MANUAL_ENTRY()
  */
-void mac_clear_multicast(smc)
-struct s_smc *smc ;
+void mac_clear_multicast(struct s_smc *smc)
 {
 	struct s_fpmc	*tb ;
 	int i ;
@@ -1198,9 +1147,7 @@
 
 	END_MANUAL_ENTRY()
  */
-int mac_set_func_addr(smc,f_addr)
-struct s_smc *smc ;
-u_long f_addr ;
+int mac_set_func_addr(struct s_smc *smc, u_long f_addr)
 {
 	smc->hw.fp.func_addr = f_addr ;
 	return(0) ;
@@ -1235,10 +1182,7 @@
 
 	END_MANUAL_ENTRY()
  */
-int mac_add_multicast(smc,addr,can)
-struct s_smc *smc ;
-struct fddi_addr *addr ;
-int can ;
+int mac_add_multicast(struct s_smc *smc, struct fddi_addr *addr, int can)
 {
 	SK_LOC_DECL(struct fddi_addr,own) ;
 	struct s_fpmc	*tb ;
@@ -1292,10 +1236,7 @@
 
 	END_MANUAL_ENTRY()
  */
-void mac_del_multicast(smc,addr,can)
-struct s_smc *smc ;
-struct fddi_addr *addr ;
-int can ;
+void mac_del_multicast(struct s_smc *smc, struct fddi_addr *addr, int can)
 {
 	SK_LOC_DECL(struct fddi_addr,own) ;
 	struct s_fpmc	*tb ;
@@ -1341,8 +1282,7 @@
 
 	END_MANUAL_ENTRY()
  */
-void mac_update_multicast(smc)
-struct s_smc *smc ;
+void mac_update_multicast(struct s_smc *smc)
 {
 	struct s_fpmc	*tb ;
 	u_char	*fu ;
@@ -1418,9 +1358,7 @@
 
 	END_MANUAL_ENTRY
  */
-void mac_set_rx_mode(smc,mode)
-struct s_smc *smc ;
-int mode ;
+void mac_set_rx_mode(struct s_smc *smc, int mode)
 {
 	switch (mode) {
 	case RX_ENABLE_ALLMULTI :
@@ -1476,8 +1414,7 @@
 
 	END_MANUAL_ENTRY
  */
-void rtm_irq(smc)
-struct s_smc *smc ;
+void rtm_irq(struct s_smc *smc)
 {
 	outpw(ADDR(B2_RTM_CRTL),TIM_CL_IRQ) ;		/* clear IRQ */
 	if (inpw(ADDR(B2_RTM_CRTL)) & TIM_RES_TOK) {
@@ -1490,15 +1427,13 @@
 	outpw(ADDR(B2_RTM_CRTL),TIM_START) ;	/* enable RTM monitoring */
 }
 
-static void rtm_init(smc)
-struct s_smc *smc ;
+static void rtm_init(struct s_smc *smc)
 {
 	outpd(ADDR(B2_RTM_INI),0) ;		/* timer = 0 */
 	outpw(ADDR(B2_RTM_CRTL),TIM_START) ;	/* enable IRQ */
 }
 
-void rtm_set_timer(smc)
-struct s_smc *smc ;
+void rtm_set_timer(struct s_smc *smc)
 {
 	/*
 	 * MIB timer and hardware timer have the same resolution of 80nS
@@ -1508,8 +1443,7 @@
 	outpd(ADDR(B2_RTM_INI),smc->mib.a[PATH0].fddiPATHT_Rmode) ;
 }
 
-static void smt_split_up_fifo(smc)
-struct s_smc *smc ;
+static void smt_split_up_fifo(struct s_smc *smc)
 {
 
 /*
@@ -1629,8 +1563,7 @@
 		smc->hw.fp.fifo.tx_a0_start, smc->hw.fp.fifo.rx2_fifo_start) ;
 }
 
-void formac_reinit_tx(smc)
-struct s_smc *smc ;
+void formac_reinit_tx(struct s_smc *smc)
 {
 	/*
 	 * Split up the FIFO and reinitialize the MAC if synchronous
@@ -1641,5 +1574,4 @@
 		(void)init_mac(smc,0) ;
 	}
 }
-
 
diff -Nru a/drivers/net/skfp/h/cmtdef.h b/drivers/net/skfp/h/cmtdef.h
--- a/drivers/net/skfp/h/cmtdef.h	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/h/cmtdef.h	2004-06-17 14:49:49 -07:00
@@ -418,7 +418,6 @@
 	void	*pc_p ;
 } ;
 
-
 /*
  * link error monitor
  */
@@ -444,7 +443,6 @@
 
 #define NUMBITS	10
 
-
 #ifdef	AMDPLC
 
 /*
@@ -480,216 +478,184 @@
  * function prototypes
  */
 #include "h/mbuf.h"	/* Type definitions for MBUFs */
-void hwt_restart(                       /* hwt.c */
-#ifdef ANSIC
-        struct s_smc *smc
-#endif
-	) ;
-
-SMbuf *smt_build_frame(                 /* smt.c */
-#ifdef ANSIC
-        struct s_smc *smc,
-        int class,
-        int type,
-        int length
-#endif
-	) ;
-
-SMbuf *smt_get_mbuf(                     /* drvsr.c */
-#ifdef ANSIC
-        struct s_smc *smc
-#endif
-	) ;
-
-void *sm_to_para(                       /* smt.c */
-#ifdef ANSIC
-	struct s_smc *smc,
-        struct smt_header *sm,
-        int para
-#endif
-	) ;
+#include "h/smtstate.h"	/* struct smt_state */
+
+void hwt_restart(struct s_smc *smc);	/* hwt.c */
+SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
+		       int length);	/* smt.c */
+SMbuf *smt_get_mbuf(struct s_smc *smc);	/* drvsr.c */
+void *sm_to_para(struct s_smc *smc, struct smt_header *sm,
+		 int para);		/* smt.c */
 
 #ifndef SK_UNUSED
 #define SK_UNUSED(var)		(void)(var)
 #endif
 
-void queue_event() ;
-void ecm() ;
-void ecm_init() ;
-void rmt() ;
-void rmt_init() ;
-void pcm() ;
-void pcm_init() ;
-void cfm() ;
-void cfm_init() ;
-void smt_timer_start() ;
-void smt_timer_stop() ;
-void pcm_status_state() ;
-void plc_config_mux() ;
-void sm_lem_evaluate() ;
-void smt_clear_una_dna() ;
-void mac_status_para() ;
-void mac_update_counter() ;
-void sm_pm_ls_latch() ;
-void sm_ma_control() ;
-void sm_mac_check_beacon_claim() ;
-void config_mux() ;
-void smt_agent_init() ;
-void smt_timer_init() ;
-void smt_received_pack() ;
-void smt_add_para() ;
-void smt_swap_para() ;
-void ev_init() ;
-void hwt_init() ;
-u_long hwt_read() ;
-void hwt_stop() ;
-void hwt_start() ;
-void smt_send_mbuf() ;
-void smt_free_mbuf() ;
-void sm_pm_bypass_req() ;
-void rmt_indication() ;
-void cfm_state_change() ;
-void rx_indication() ;
-void tx_indication() ;
-#ifndef NO_SMT_PANIC
-void smt_panic() ;
-#else
-#ifdef	DEBUG
-void smt_panic() ;
+void queue_event(struct s_smc *smc, int class, int event);
+void ecm(struct s_smc *smc, int event);
+void ecm_init(struct s_smc *smc);
+void rmt(struct s_smc *smc, int event);
+void rmt_init(struct s_smc *smc);
+void pcm(struct s_smc *smc, const int np, int event);
+void pcm_init(struct s_smc *smc);
+void cfm(struct s_smc *smc, int event);
+void cfm_init(struct s_smc *smc);
+void smt_timer_start(struct s_smc *smc, struct smt_timer *timer, u_long time,
+		     u_long token);
+void smt_timer_stop(struct s_smc *smc, struct smt_timer *timer);
+void pcm_status_state(struct s_smc *smc, int np, int *type, int *state,
+		      int *remote, int *mac);
+void plc_config_mux(struct s_smc *smc, int mux);
+void sm_lem_evaluate(struct s_smc *smc);
+void smt_clear_una_dna(struct s_smc *smc);
+void mac_update_counter(struct s_smc *smc);
+void sm_pm_ls_latch(struct s_smc *smc, int phy, int on_off);
+void sm_ma_control(struct s_smc *smc, int mode);
+void sm_mac_check_beacon_claim(struct s_smc *smc);
+void config_mux(struct s_smc *smc, int mux);
+void smt_agent_init(struct s_smc *smc);
+void smt_timer_init(struct s_smc *smc);
+void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs);
+void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
+		  int index, int local);
+void smt_swap_para(struct smt_header *sm, int len, int direction);
+void ev_init(struct s_smc *smc);
+void hwt_init(struct s_smc *smc);
+u_long hwt_read(struct s_smc *smc);
+void hwt_stop(struct s_smc *smc);
+void hwt_start(struct s_smc *smc, u_long time);
+void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc);
+void smt_free_mbuf(struct s_smc *smc, SMbuf *mb);
+void sm_pm_bypass_req(struct s_smc *smc, int mode);
+void rmt_indication(struct s_smc *smc, int i);
+void cfm_state_change(struct s_smc *smc, int c_state);
+
+#if defined(DEBUG) || !defined(NO_SMT_PANIC)
+void smt_panic(struct s_smc *smc, char *text);
 #else
 #define	smt_panic(smc,text)
-#endif	/* DEBUG */
-#endif	/* NO_SMT_PANIC */
-void smt_stat_counter() ;
-void smt_timer_poll() ;
-u_long smt_get_time() ;
-u_long smt_get_tid() ;
-void smt_timer_done() ;
-void smt_set_defaults() ;
-void smt_fixup_mib() ;
-void smt_reset_defaults() ;
-void smt_agent_task() ;
-void smt_please_reconnect() ;
-int smt_check_para() ;
-void driver_get_bia() ;
-#ifdef	SUPERNET_3
-void drv_reset_indication() ;
+#endif /* DEBUG || !NO_SMT_PANIC */
+
+void smt_stat_counter(struct s_smc *smc, int stat);
+void smt_timer_poll(struct s_smc *smc);
+u_long smt_get_time(void);
+u_long smt_get_tid(struct s_smc *smc);
+void smt_timer_done(struct s_smc *smc);
+void smt_set_defaults(struct s_smc *smc);
+void smt_fixup_mib(struct s_smc *smc);
+void smt_reset_defaults(struct s_smc *smc, int level);
+void smt_agent_task(struct s_smc *smc);
+void smt_please_reconnect(struct s_smc *smc, int reconn_time);
+int smt_check_para(struct s_smc *smc, struct smt_header *sm,
+		   const u_short list[]);
+void driver_get_bia(struct s_smc *smc, struct fddi_addr *bia_addr);
+
+#ifdef SUPERNET_3
+void drv_reset_indication(struct s_smc *smc);
 #endif	/* SUPERNET_3 */
-void smt_start_watchdog() ;
 
-void smt_event() ;
-void pcm_event() ;
-void rmt_event() ;
-void cfm_event() ;
-void timer_event() ;
-void ev_dispatcher() ;
-
-void smt_get_state() ;
-void ecm_get_state() ;
-void pcm_get_state() ;
-void rmt_get_state() ;
-
-void ecm_state_change() ;
-int sm_pm_bypass_present() ;
-void pcm_state_change() ;
-void rmt_state_change() ;
-int sm_pm_get_ls() ;
-int pcm_get_s_port() ;
-int pcm_rooted_station() ;
-int cfm_get_mac_input() ;
-int cfm_get_mac_output() ;
-int port_to_mib() ;
-int cem_build_path() ;
-int sm_mac_get_tx_state() ;
-int is_individual() ;
-int is_my_addr() ;
-int is_broadcast() ;
-int is_equal() ;
-char *get_pcmstate() ;
-
-int smt_action() ;
-u_short smt_online() ;
-void smt_force_irq() ;
-void smt_pmf_received_pack() ;
-void smt_send_frame() ;
-void smt_set_timestamp() ;
-void mac_set_rx_mode() ;
-int mac_add_multicast() ;
-int mac_set_func_addr() ;
-void mac_del_multicast() ;
-void mac_update_multicast() ;
-void mac_clear_multicast() ;
-void mac_rx_directed_beacon() ;
-void set_formac_tsync() ;
-void formac_reinit_tx() ;
-void formac_tx_restart() ;
-void process_receive() ;
-void init_driver_fplus() ;
-
-void rtm_irq() ;
-void rtm_set_timer() ;
-void ring_status_indication() ;
-void llc_recover_tx() ;
-void llc_restart_tx() ;
-void plc_clear_irq() ;
-void plc_irq() ;
-int smt_set_mac_opvalues() ;
-#ifdef	TAG_MODE
-void mac_drv_pci_fix() ;
-void mac_do_pci_fix() ;
-void mac_drv_clear_tx_queue() ;
-void mac_drv_repair_descr() ;
-u_long hwt_quick_read() ;
-void hwt_wait_time() ;
+void smt_start_watchdog(struct s_smc *smc);
+void smt_event(struct s_smc *smc, int event);
+void timer_event(struct s_smc *smc, u_long token);
+void ev_dispatcher(struct s_smc *smc);
+void pcm_get_state(struct s_smc *smc, struct smt_state *state);
+void ecm_state_change(struct s_smc *smc, int e_state);
+int sm_pm_bypass_present(struct s_smc *smc);
+void pcm_state_change(struct s_smc *smc, int plc, int p_state);
+void rmt_state_change(struct s_smc *smc, int r_state);
+int sm_pm_get_ls(struct s_smc *smc, int phy);
+int pcm_get_s_port(struct s_smc *smc);
+int pcm_rooted_station(struct s_smc *smc);
+int cfm_get_mac_input(struct s_smc *smc);
+int cfm_get_mac_output(struct s_smc *smc);
+int port_to_mib(struct s_smc *smc, int p);
+int cem_build_path(struct s_smc *smc, char *to, int path_index);
+int sm_mac_get_tx_state(struct s_smc *smc);
+int is_individual(struct fddi_addr *addr);
+int is_my_addr(struct s_smc *smc, struct fddi_addr *addr);
+int is_broadcast(struct fddi_addr *addr);
+int is_equal(struct fddi_addr *addr1, struct fddi_addr *addr2);
+char *get_pcmstate(struct s_smc *smc, int np);
+int smt_action(struct s_smc *smc, int class, int code, int index);
+u_short smt_online(struct s_smc *smc, int on);
+void smt_force_irq(struct s_smc *smc);
+void smt_pmf_received_pack(struct s_smc *smc, SMbuf *mb, int local);
+void smt_send_frame(struct s_smc *smc, SMbuf *mb, int fc, int local);
+void smt_set_timestamp(struct s_smc *smc, u_char *p);
+void mac_set_rx_mode(struct s_smc *smc,	int mode);
+int mac_add_multicast(struct s_smc *smc, struct fddi_addr *addr, int can);
+int mac_set_func_addr(struct s_smc *smc, u_long f_addr);
+void mac_del_multicast(struct s_smc *smc, struct fddi_addr *addr, int can);
+void mac_update_multicast(struct s_smc *smc);
+void mac_clear_multicast(struct s_smc *smc);
+void set_formac_tsync(struct s_smc *smc, long sync_bw);
+void formac_reinit_tx(struct s_smc *smc);
+void formac_tx_restart(struct s_smc *smc);
+void process_receive(struct s_smc *smc);
+void init_driver_fplus(struct s_smc *smc);
+void rtm_irq(struct s_smc *smc);
+void rtm_set_timer(struct s_smc *smc);
+void ring_status_indication(struct s_smc *smc, u_long status);
+void llc_recover_tx(struct s_smc *smc);
+void llc_restart_tx(struct s_smc *smc);
+void plc_clear_irq(struct s_smc *smc, int p);
+void plc_irq(struct s_smc *smc,	int np,	unsigned int cmd);
+int smt_set_mac_opvalues(struct s_smc *smc);
+
+#ifdef TAG_MODE
+void mac_drv_pci_fix(struct s_smc *smc, u_long fix_value);
+void mac_do_pci_fix(struct s_smc *smc);
+void mac_drv_clear_tx_queue(struct s_smc *smc);
+void mac_drv_repair_descr(struct s_smc *smc);
+u_long hwt_quick_read(struct s_smc *smc);
+void hwt_wait_time(struct s_smc *smc, u_long start, long duration);
 #endif
 
 #ifdef SMT_PNMI
-#ifdef ANSIC
-int pnmi_init (struct s_smc* smc);
-int pnmi_process_ndis_id (struct s_smc* smc, u_long ndis_oid, void* buf,
-		int len, int* BytesAccessed, int* BytesNeeded, u_char action);
-#else
-int pnmi_init ();
-int pnmi_process_ndis_id ();
-#endif
+int pnmi_init(struct s_smc* smc);
+int pnmi_process_ndis_id(struct s_smc *smc, u_long ndis_oid, void *buf, int len,
+			 int *BytesAccessed, int *BytesNeeded, u_char action);
 #endif
 
 #ifdef	SBA
 #ifndef _H2INC
-void sba() ;
+void sba();
 #endif
-void sba_raf_received_pack() ;
-void sba_timer_poll() ;
-void smt_init_sba() ;
+void sba_raf_received_pack();
+void sba_timer_poll();
+void smt_init_sba();
 #endif
+
 #ifdef	ESS
-int ess_raf_received_pack() ;
-void ess_timer_poll() ;
-void ess_para_change() ;
+int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
+			  int fs);
+void ess_timer_poll(struct s_smc *smc);
+void ess_para_change(struct s_smc *smc);
 #endif
 
-#ifdef	BOOT
-#define smt_srf_event(a,b,c,d)
-#define smt_init_evc(a)
+#ifndef	BOOT
+void smt_init_evc(struct s_smc *smc);
+void smt_srf_event(struct s_smc *smc, int code, int index, int cond);
 #else
-void smt_init_evc() ;
-void smt_srf_event() ;
+#define smt_init_evc(smc)
+#define smt_srf_event(smc,code,index,cond)
 #endif
 
 #ifndef SMT_REAL_TOKEN_CT
-void smt_emulate_token_ct();
+void smt_emulate_token_ct(struct s_smc *smc, int mac_index);
 #endif
 
 #if defined(DEBUG) && !defined(BOOT)
-void dump_smt() ;
+void dump_smt(struct s_smc *smc, struct smt_header *sm, char *text);
 #else
 #define	dump_smt(smc,sm,text)
 #endif
 
 #ifdef	DEBUG
-char	*addr_to_string() ;
-void	dump_hex() ;
+char* addr_to_string(struct fddi_addr *addr);
+void dump_hex(char *p, int len);
 #endif
+
 #endif	/* PROTOTYP_INC */
 
 /* PNMI default defines */
diff -Nru a/drivers/net/skfp/h/smtstate.h b/drivers/net/skfp/h/smtstate.h
--- a/drivers/net/skfp/h/smtstate.h	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/h/smtstate.h	2004-06-17 14:49:49 -07:00
@@ -12,6 +12,9 @@
  *
  ******************************************************************************/
 
+#ifndef _SKFP_H_SMTSTATE_H_
+#define _SKFP_H_SMTSTATE_H_
+
 /*
  *	SMT state definitions
  */
@@ -98,3 +101,6 @@
 struct smt_state {
 	struct pcm_state pcm_state[NUMPHYS] ;	/* port A & port B */
 } ;
+
+#endif
+
diff -Nru a/drivers/net/skfp/hwmtm.c b/drivers/net/skfp/hwmtm.c
--- a/drivers/net/skfp/hwmtm.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/hwmtm.c	2004-06-17 14:49:49 -07:00
@@ -75,15 +75,17 @@
 	-------------------------------------------------------------
 */
 
-static	void	queue_llc_rx(),		smt_to_llc(),
-		init_txd_ring(),	init_rxd_ring(),
-		queue_txd_mb() ;
-
-static	u_long	init_descr_ring(),	repair_txd_ring(),
-		repair_rxd_ring() ;
-
-static	SMbuf	*get_llc_rx(),		*get_txd_mb() ;
-
+static void queue_llc_rx(struct s_smc *smc, SMbuf *mb);
+static void smt_to_llc(struct s_smc *smc, SMbuf *mb);
+static void init_txd_ring(struct s_smc *smc);
+static void init_rxd_ring(struct s_smc *smc);
+static void queue_txd_mb(struct s_smc *smc, SMbuf *mb);
+static u_long init_descr_ring(struct s_smc *smc, union s_fp_descr volatile *start,
+			      int count);
+static u_long repair_txd_ring(struct s_smc *smc, struct s_smt_tx_queue *queue);
+static u_long repair_rxd_ring(struct s_smc *smc, struct s_smt_rx_queue *queue);
+static SMbuf* get_llc_rx(struct s_smc *smc);
+static SMbuf* get_txd_mb(struct s_smc *smc);
 
 /*
 	-------------------------------------------------------------
@@ -92,55 +94,81 @@
 */
 /*	The external SMT functions are listed in cmtdef.h */
 
-extern	void	*mac_drv_get_space(),	*mac_drv_get_desc_mem(),
-		init_board(),		mac_drv_fill_rxd(),
-		plc1_irq(),		mac_drv_tx_complete(),
-		plc2_irq(),		mac1_irq(),
-		mac2_irq(),		mac3_irq(),
-		timer_irq(),		mac_drv_rx_complete(),
-		mac_drv_requeue_rxd(),	init_plc(),
-		mac_drv_clear_rxd(),	llc_restart_tx(),
-		ev_dispatcher(),	smt_force_irq() ;
+extern void* mac_drv_get_space(struct s_smc *smc, unsigned int size);
+extern void* mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size);
+extern void init_board(struct s_smc *smc, u_char *mac_addr);
+extern void mac_drv_fill_rxd(struct s_smc *smc);
+extern void plc1_irq(struct s_smc *smc);
+extern void mac_drv_tx_complete(struct s_smc *smc,
+				volatile struct s_smt_fp_txd *txd);
+extern void plc2_irq(struct s_smc *smc);
+extern void mac1_irq(struct s_smc *smc, u_short stu, u_short stl);
+extern void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l);
+extern void mac3_irq(struct s_smc *smc, u_short code_s3u, u_short code_s3l);
+extern void timer_irq(struct s_smc *smc);
+extern void mac_drv_rx_complete(struct s_smc *smc,
+				volatile struct s_smt_fp_rxd *rxd,
+				int frag_count, int len);
+extern void mac_drv_requeue_rxd(struct s_smc *smc, 
+				volatile struct s_smt_fp_rxd *rxd,
+				int frag_count);
+extern void init_plc(struct s_smc *smc);
+extern void mac_drv_clear_rxd(struct s_smc *smc,
+			      volatile struct s_smt_fp_rxd *rxd, int frag_count);
 
 #ifdef	USE_OS_CPY
-extern	void	hwm_cpy_rxd2mb(),	hwm_cpy_txd2mb() ;
+extern void hwm_cpy_rxd2mb(void);
+extern void hwm_cpy_txd2mb(void);
 #endif
+
 #ifdef	ALL_RX_COMPLETE
-extern	void	mac_drv_all_receives_complete() ;
+extern void mac_drv_all_receives_complete(void);
 #endif
 
-extern	u_long	mac_drv_virt2phys(),	dma_master() ;
+extern u_long mac_drv_virt2phys(struct s_smc *smc, void *virt);
+extern u_long dma_master(struct s_smc *smc, void *virt, int len, int flag);
 
 #ifdef	NDIS_OS2
-extern	void	post_proc() ;
+extern void post_proc(void);
 #else
-extern	void	dma_complete() ;
+extern void dma_complete(struct s_smc *smc, volatile union s_fp_descr *descr,
+			 int flag);
 #endif
 
-extern	int	init_fplus(),		mac_drv_rx_init() ;
+extern int init_fplus(struct s_smc *smc);
+extern int mac_drv_rx_init(struct s_smc *smc, int len, int fc, char *look_ahead,
+			   int la_len);
 
 /*
 	-------------------------------------------------------------
 	PUBLIC FUNCTIONS:
 	-------------------------------------------------------------
 */
-	void	process_receive(),	smt_send_mbuf(),
-		fddi_isr(),		mac_drv_clear_txd(),
-		smt_free_mbuf(),	init_driver_fplus(),
-		mac_drv_rx_mode(),	init_fddi_driver(),
-		mac_drv_clear_tx_queue(),
-		mac_drv_clear_rx_queue(),
-		hwm_tx_frag(),		hwm_rx_frag() ;
-
-	int	mac_drv_rx_frag(),	mac_drv_init(),
-		hwm_tx_init() ;
+void process_receive(struct s_smc *smc);
+void fddi_isr(struct s_smc *smc);
+void mac_drv_clear_txd(struct s_smc *smc);
+void smt_free_mbuf(struct s_smc *smc, SMbuf *mb);
+void init_driver_fplus(struct s_smc *smc);
+void mac_drv_rx_mode(struct s_smc *smc, int mode);
+void init_fddi_driver(struct s_smc *smc, u_char *mac_addr);
+void mac_drv_clear_tx_queue(struct s_smc *smc);
+void mac_drv_clear_rx_queue(struct s_smc *smc);
+void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
+		 int frame_status);
+void hwm_rx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
+		 int frame_status);
+
+int mac_drv_rx_frag(struct s_smc *smc, void far *virt, int len);
+int mac_drv_init(struct s_smc *smc);
+int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count, int frame_len,
+		int frame_status);
 
-	u_int	mac_drv_check_space() ;
+u_int mac_drv_check_space(void);
 
-	SMbuf 	*smt_get_mbuf() ;
+SMbuf* smt_get_mbuf(struct s_smc *smc);
 
 #ifdef DEBUG
-	void	mac_drv_debug_lev() ;
+	void mac_drv_debug_lev(void);
 #endif
 
 /*
@@ -208,7 +236,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-u_int mac_drv_check_space()
+u_int mac_drv_check_space(void)
 {
 #ifdef	MB_OUTSIDE_SMC
 #ifdef	COMMON_MB_POOL
@@ -238,8 +266,7 @@
  *			mac_drv_init once, after the adatper is detected.
  *	END_MANUAL_ENTRY
  */
-int mac_drv_init(smc)
-struct s_smc *smc ;
+int mac_drv_init(struct s_smc *smc)
 {
 	if (sizeof(struct s_smt_fp_rxd) % 16) {
 		SMT_PANIC(smc,HWM_E0001,HWM_E0001_MSG) ;
@@ -289,8 +316,7 @@
  *	 least significant byte etc.)
  *	END_MANUAL_ENTRY
  */
-void init_driver_fplus(smc)
-struct s_smc *smc ;
+void init_driver_fplus(struct s_smc *smc)
 {
 	smc->hw.fp.mdr2init = FM_LSB | FM_BMMODE | FM_ENNPRQ | FM_ENHSRQ | 3 ;
 
@@ -305,10 +331,9 @@
 #endif
 }
 
-static u_long init_descr_ring(smc,start,count)
-struct s_smc *smc ;
-union s_fp_descr volatile *start;
-int count ;
+static u_long init_descr_ring(struct s_smc *smc,
+			      union s_fp_descr volatile *start,
+			      int count)
 {
 	int i ;
 	union s_fp_descr volatile *d1 ;
@@ -337,8 +362,7 @@
 	return(phys) ;
 }
 
-static void init_txd_ring(smc)
-struct s_smc *smc ;
+static void init_txd_ring(struct s_smc *smc)
 {
 	struct s_smt_fp_txd volatile *ds ;
 	struct s_smt_tx_queue *queue ;
@@ -375,8 +399,7 @@
 	outpd(ADDR(B5_XS_DA),phys) ;
 }
 
-static void init_rxd_ring(smc)
-struct s_smc *smc ;
+static void init_rxd_ring(struct s_smc *smc)
 {
 	struct s_smt_fp_rxd volatile *ds ;
 	struct s_smt_rx_queue *queue ;
@@ -406,9 +429,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void init_fddi_driver(smc,mac_addr)
-struct	s_smc	*smc ;
-u_char		*mac_addr ;	/* canonical address */
+void init_fddi_driver(struct s_smc *smc, u_char *mac_addr)
 {
 	SMbuf	*mb ;
 	int	i ;
@@ -472,8 +493,7 @@
 }
 
 
-SMbuf *smt_get_mbuf(smc)
-struct s_smc *smc ;
+SMbuf *smt_get_mbuf(struct s_smc *smc)
 {
 	register SMbuf	*mb ;
 
@@ -495,9 +515,7 @@
 	return (mb) ;	/* May be NULL */
 }
 
-void smt_free_mbuf(smc, mb)
-struct s_smc	*smc ;
-SMbuf		*mb;
+void smt_free_mbuf(struct s_smc *smc, SMbuf *mb)
 {
 
 	if (mb) {
@@ -543,8 +561,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_repair_descr(smc)
-struct s_smc *smc ;
+void mac_drv_repair_descr(struct s_smc *smc)
 {
 	u_long	phys ;
 
@@ -576,9 +593,7 @@
 	outpd(ADDR(B0_R1_CSR),CSR_START) ;
 }
 
-static u_long repair_txd_ring(smc,queue)
-struct s_smc *smc ;
-struct s_smt_tx_queue *queue ;
+static u_long repair_txd_ring(struct s_smc *smc, struct s_smt_tx_queue *queue)
 {
 	int i ;
 	int tx_used ;
@@ -630,9 +645,7 @@
  *	  RxDs with an OWN bit set but with a reset STF bit should be
  *	  skipped and owned by the driver (OWN = 0). 
  */
-static u_long repair_rxd_ring(smc,queue)
-struct s_smc *smc ;
-struct s_smt_rx_queue *queue ;
+static u_long repair_rxd_ring(struct s_smc *smc, struct s_smt_rx_queue *queue)
 {
 	int i ;
 	int rx_used ;
@@ -703,8 +716,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void fddi_isr(smc)
-struct s_smc *smc ;
+void fddi_isr(struct s_smc *smc)
 {
 	u_long		is ;		/* ISR source */
 	u_short		stu, stl ;
@@ -987,9 +999,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_rx_mode(smc,mode)
-struct s_smc *smc ;
-int mode ;
+void mac_drv_rx_mode(struct s_smc *smc, int mode)
 {
 	switch(mode) {
 	case RX_ENABLE_PASS_SMT:
@@ -1038,8 +1048,7 @@
 /*
  * process receive queue
  */
-void process_receive(smc)
-struct s_smc *smc ;
+void process_receive(struct s_smc *smc)
 {
 	int i ;
 	int n ;
@@ -1379,9 +1388,7 @@
 	return ;	/* lint bug: needs return detect end of function */
 }
 
-static void smt_to_llc(smc,mb)
-struct s_smc *smc ;
-SMbuf *mb ;
+static void smt_to_llc(struct s_smc *smc, SMbuf *mb)
 {
 	u_char	fc ;
 
@@ -1416,12 +1423,8 @@
  *
  *	END_MANUAL_ENTRY
  */
-void hwm_rx_frag(smc,virt,phys,len,frame_status)
-struct s_smc *smc ;
-char far *virt ;
-u_long phys ;
-int len ;
-int frame_status ;
+void hwm_rx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
+		 int frame_status)
 {
 	struct s_smt_fp_rxd volatile *r ;
 	u_int	rbctrl ;
@@ -1460,10 +1463,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-int mac_drv_rx_frag(smc,virt,len)
-struct s_smc *smc ;
-void far *virt ;
-int len ;
+int mac_drv_rx_frag(struct s_smc *smc, void far *virt, int len)
 {
 	NDD_TRACE("RHSB",virt,len,smc->os.hwm.r.mb_pos) ;
 
@@ -1500,8 +1500,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_clear_rx_queue(smc)
-struct s_smc *smc ;
+void mac_drv_clear_rx_queue(struct s_smc *smc)
 {
 	struct s_smt_fp_rxd volatile *r ;
 	struct s_smt_fp_rxd volatile *next_rxd ;
@@ -1588,12 +1587,8 @@
  *
  *	END_MANUAL_ENTRY
  */
-int hwm_tx_init(smc,fc,frag_count,frame_len,frame_status)
-struct	s_smc *smc ;
-u_char fc ;
-int frag_count ;
-int frame_len ;
-int frame_status ;
+int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count, int frame_len,
+		int frame_status)
 {
 	NDD_TRACE("THiB",fc,frag_count,frame_len) ;
 	smc->os.hwm.tx_p = smc->hw.fp.tx[frame_status & QUEUE_A0] ;
@@ -1670,12 +1665,8 @@
  *
  *	END_MANUAL_ENTRY
  */
-void hwm_tx_frag(smc,virt,phys,len,frame_status)
-struct	s_smc *smc ;
-char far *virt ;
-u_long phys ;
-int len ;
-int frame_status ;
+void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
+		 int frame_status)
 {
 	struct s_smt_fp_txd volatile *t ;
 	struct s_smt_tx_queue *queue ;
@@ -1780,9 +1771,7 @@
 /*
  * queues a receive for later send
  */
-static void queue_llc_rx(smc,mb)
-struct	s_smc *smc ;
-SMbuf	*mb ;
+static void queue_llc_rx(struct s_smc *smc, SMbuf *mb)
 {
 	DB_GEN("queue_llc_rx: mb = %x",(void *)mb,0,4) ;
 	smc->os.hwm.queued_rx_frames++ ;
@@ -1806,8 +1795,7 @@
 /*
  * get a SMbuf from the llc_rx_queue
  */
-static SMbuf *get_llc_rx(smc)
-struct	s_smc *smc ;
+static SMbuf *get_llc_rx(struct s_smc *smc)
 {
 	SMbuf	*mb ;
 
@@ -1823,9 +1811,7 @@
  * queues a transmit SMT MBuf during the time were the MBuf is
  * queued the TxD ring
  */
-static void queue_txd_mb(smc,mb)
-struct	s_smc *smc ;
-SMbuf	*mb ;
+static void queue_txd_mb(struct s_smc *smc, SMbuf *mb)
 {
 	DB_GEN("_rx: queue_txd_mb = %x",(void *)mb,0,4) ;
 	smc->os.hwm.queued_txd_mb++ ;
@@ -1842,8 +1828,7 @@
 /*
  * get a SMbuf from the txd_tx_queue
  */
-static SMbuf *get_txd_mb(smc)
-struct	s_smc *smc ;
+static SMbuf *get_txd_mb(struct s_smc *smc)
 {
 	SMbuf *mb ;
 
@@ -1858,10 +1843,7 @@
 /*
  *	SMT Send function
  */
-void smt_send_mbuf(smc,mb,fc)
-struct s_smc	*smc;
-SMbuf		*mb;
-int		fc;
+void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 {
 	char far *data ;
 	int	len ;
@@ -1995,8 +1977,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_clear_txd(smc)
-struct s_smc *smc ;
+void mac_drv_clear_txd(struct s_smc *smc)
 {
 	struct s_smt_tx_queue *queue ;
 	struct s_smt_fp_txd volatile *t1 ;
@@ -2087,8 +2068,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_clear_tx_queue(smc)
-struct s_smc *smc ;
+void mac_drv_clear_tx_queue(struct s_smc *smc)
 {
 	struct s_smt_fp_txd volatile *t ;
 	struct s_smt_tx_queue *queue ;
@@ -2180,10 +2160,7 @@
  *
  *	END_MANUAL_ENTRY
  */
-void mac_drv_debug_lev(smc,flag,lev)
-struct s_smc *smc ;
-int flag ;
-int lev ;
+void mac_drv_debug_lev(struct s_smc *smc, int flag, int lev)
 {
 	switch(flag) {
 	case (int)NULL:
diff -Nru a/drivers/net/skfp/hwt.c b/drivers/net/skfp/hwt.c
--- a/drivers/net/skfp/hwt.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/hwt.c	2004-06-17 14:49:49 -07:00
@@ -39,7 +39,7 @@
  * Prototypes of local functions.
  */
 /* 28-Jun-1994 sw - Note: hwt_restart() is also used in module 'drvfbi.c'. */
-/*static*/ void hwt_restart() ;
+/*static void hwt_restart() ; */
 
 /************************
  *
@@ -60,9 +60,7 @@
  ************************/
 #define	HWT_MAX	(65000)
 
-void hwt_start(smc, time)
-struct s_smc *smc ;
-u_long time ;
+void hwt_start(struct s_smc *smc, u_long time)
 {
 	u_short	cnt ;
 
@@ -115,8 +113,7 @@
  *	Nothing.
  *
  ************************/
-void hwt_stop(smc)
-struct s_smc *smc ;
+void hwt_stop(struct s_smc *smc)
 {
 #ifndef PCI
 	/* stop counter 0 by switching to mode 0 */
@@ -145,8 +142,7 @@
  *	Nothing.
  *
  ************************/
-void hwt_init(smc)
-struct s_smc *smc ;
+void hwt_init(struct s_smc *smc)
 {
 	smc->hw.t_start = 0 ;
 	smc->hw.t_stop	= 0 ;
@@ -169,8 +165,7 @@
  *	Nothing.
  *
  ************************/
-void hwt_restart(smc)
-struct s_smc *smc ;
+void hwt_restart(struct s_smc *smc)
 {
 	hwt_stop(smc) ;
 #ifndef	PCI
@@ -193,8 +188,7 @@
  *	The elapsed time since last start in units of 16us.
  *
  ************************/
-u_long hwt_read(smc)
-struct s_smc *smc ;
+u_long hwt_read(struct s_smc *smc)
 {
 	u_short	tr ;
 #ifndef	PCI
@@ -238,8 +232,7 @@
  *	current timer value in units of 80ns.
  *
  ************************/
-u_long hwt_quick_read(smc)
-struct s_smc *smc ;
+u_long hwt_quick_read(struct s_smc *smc)
 {
 	u_long interval ;
 	u_long time ;
@@ -267,10 +260,7 @@
  * NOTE: The fuction will return immediately, if the timer is not 
  *	 started
  ************************/
-void hwt_wait_time(smc,start,duration)
-struct s_smc *smc ;
-u_long	start ;
-long	duration ;
+void hwt_wait_time(struct s_smc *smc, u_long start, long int duration)
 {
 	long	diff ;
 	long	interval ;
@@ -312,3 +302,4 @@
 	}
 }
 #endif
+
diff -Nru a/drivers/net/skfp/lnkstat.c b/drivers/net/skfp/lnkstat.c
--- a/drivers/net/skfp/lnkstat.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/lnkstat.c	2004-06-17 14:49:49 -07:00
@@ -52,8 +52,7 @@
 
 	END_MANUAL_ENTRY()
  */
-u_long smt_get_error_word(smc)
-struct s_smc *smc ;
+u_long smt_get_error_word(struct s_smc *smc)
 {
 	u_long	st;
 
@@ -92,8 +91,7 @@
 
 	END_MANUAL_ENTRY()
  */
-u_long smt_get_event_word(smc)
-struct s_smc *smc ;
+u_long smt_get_event_word(struct s_smc *smc)
 {
 	return (u_long) 0;
 }
@@ -111,8 +109,7 @@
 
 	END_MANUAL_ENTRY()
  */
-u_long smt_get_port_event_word(smc)
-struct s_smc *smc ;
+u_long smt_get_port_event_word(struct s_smc *smc)
 {
 	return (u_long) 0;
 }
@@ -135,10 +132,7 @@
 
 	END_MANUAL_ENTRY()
  */
-int smt_read_errorlog(smc,p,len)
-struct s_smc *smc ;
-char _far *p ;
-int len ;
+int smt_read_errorlog(struct s_smc *smc, char _far *p, int len)
 {
 	int			i ;
 	int			st ;
@@ -207,3 +201,4 @@
 		er->ucode_version_level = 0x0101 ;
 	return(len) ;
 }
+
diff -Nru a/drivers/net/skfp/pcmplc.c b/drivers/net/skfp/pcmplc.c
--- a/drivers/net/skfp/pcmplc.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/pcmplc.c	2004-06-17 14:49:49 -07:00
@@ -199,28 +199,25 @@
 			PL_PCM_ENABLED | PL_SELF_TEST | PL_EBUF_ERR;
 
 /* external functions */
-void	all_selection_criteria ();
+void all_selection_criteria(struct s_smc *smc);
 
 /* internal functions */
-static void pcm_fsm() ;
-static void pc_rcode_actions() ;
-static void pc_tcode_actions() ;
-static void reset_lem_struct() ;
-static void plc_init() ;
-static void sm_ph_lem_start() ;
-static void sm_ph_lem_stop() ;
-static void sm_ph_linestate() ;
-static void real_init_plc() ;
+static void pcm_fsm(struct s_smc *smc, struct s_phy *phy, int cmd);
+static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy);
+static void pc_tcode_actions(struct s_smc *smc, const int bit, struct s_phy *phy);
+static void reset_lem_struct(struct s_phy *phy);
+static void plc_init(struct s_smc *smc, int p);
+static void sm_ph_lem_start(struct s_smc *smc, int np, int threshold);
+static void sm_ph_lem_stop(struct s_smc *smc, int np);
+static void sm_ph_linestate(struct s_smc *smc, int phy, int ls);
+static void real_init_plc(struct s_smc *smc);
 
 /*
  * SMT timer interface
  *      start PCM timer 0
  */
-static void start_pcm_timer0(smc,value,event,phy)
-struct s_smc *smc ;
-u_long value;
-int event;
-struct s_phy *phy;
+static void start_pcm_timer0(struct s_smc *smc, u_long value, int event,
+			     struct s_phy *phy)
 {
 	phy->timer0_exp = FALSE ;       /* clear timer event flag */
 	smt_timer_start(smc,&phy->pcm_timer0,value,
@@ -230,9 +227,7 @@
  * SMT timer interface
  *      stop PCM timer 0
  */
-static void stop_pcm_timer0(smc,phy)
-struct s_smc *smc ;
-struct s_phy *phy;
+static void stop_pcm_timer0(struct s_smc *smc, struct s_phy *phy)
 {
 	if (phy->pcm_timer0.tm_active)
 		smt_timer_stop(smc,&phy->pcm_timer0) ;
@@ -242,8 +237,7 @@
 	init PCM state machine (called by driver)
 	clear all PCM vars and flags
 */
-void pcm_init(smc)
-struct s_smc *smc ;
+void pcm_init(struct s_smc *smc)
 {
 	int		i ;
 	int		np ;
@@ -407,8 +401,7 @@
 	real_init_plc(smc) ;
 }
 
-void init_plc(smc)
-struct s_smc *smc ;
+void init_plc(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;
 
@@ -421,8 +414,7 @@
 	 */
 }
 
-static void real_init_plc(smc)
-struct s_smc *smc ;
+static void real_init_plc(struct s_smc *smc)
 {
 	int	p ;
 
@@ -430,9 +422,7 @@
 		plc_init(smc,p) ;
 }
 
-static void plc_init(smc,p)
-struct s_smc *smc ;
-int p;
+static void plc_init(struct s_smc *smc, int p)
 {
 	int	i ;
 #ifndef	MOT_ELM
@@ -495,10 +485,7 @@
 /*
  * control PCM state machine
  */
-static void plc_go_state(smc,p,state)
-struct s_smc *smc ;
-int p;
-int state;
+static void plc_go_state(struct s_smc *smc, int p, int state)
 {
 	HW_PTR port ;
 	int val ;
@@ -514,9 +501,7 @@
 /*
  * read current line state (called by ECM & PCM)
  */
-int sm_pm_get_ls(smc,phy)
-struct s_smc *smc ;
-int phy;
+int sm_pm_get_ls(struct s_smc *smc, int phy)
 {
 	int	state ;
 
@@ -549,10 +534,7 @@
 	return(state) ;
 }
 
-static int plc_send_bits(smc,phy,len)
-struct s_smc *smc ;
-struct s_phy *phy;
-int len;
+static int plc_send_bits(struct s_smc *smc, struct s_phy *phy, int len)
 {
 	int np = phy->np ;		/* PHY index */
 	int	n ;
@@ -589,9 +571,7 @@
 /*
  * config plc muxes
  */
-void plc_config_mux(smc,mux)
-struct s_smc *smc ;
-int mux ;
+void plc_config_mux(struct s_smc *smc, int mux)
 {
 	if (smc->s.sas != SMT_DAS)
 		return ;
@@ -615,10 +595,7 @@
 		process event
 	until SM is stable
 */
-void pcm(smc,np,event)
-struct s_smc *smc ;
-const int np;
-int event;
+void pcm(struct s_smc *smc, const int np, int event)
 {
 	int	state ;
 	int	oldstate ;
@@ -697,10 +674,7 @@
 /*
  * PCM state machine
  */
-static void pcm_fsm(smc,phy,cmd)
-struct s_smc *smc ;
-struct s_phy *phy;
-int cmd;
+static void pcm_fsm(struct s_smc *smc, struct s_phy *phy, int cmd)
 {
 	int	i ;
 	int	np = phy->np ;		/* PHY index */
@@ -1063,10 +1037,7 @@
 /*
  * force line state on a PHY output	(only in MAINT state)
  */
-static void sm_ph_linestate(smc,phy,ls)
-struct s_smc *smc ;
-int phy;
-int ls;
+static void sm_ph_linestate(struct s_smc *smc, int phy, int ls)
 {
 	int	cntrl ;
 
@@ -1095,9 +1066,7 @@
 	outpw(PLC(phy,PL_CNTRL_B),cntrl) ;
 }
 
-
-static void reset_lem_struct(phy)
-struct s_phy *phy;
+static void reset_lem_struct(struct s_phy *phy)
 {
 	struct lem_counter *lem = &phy->lem ;
 
@@ -1108,9 +1077,7 @@
 /*
  * link error monitor
  */
-static void lem_evaluate(smc,phy)
-struct s_smc *smc ;
-struct s_phy *phy;
+static void lem_evaluate(struct s_smc *smc, struct s_phy *phy)
 {
 	int ber ;
 	u_long errors ;
@@ -1210,8 +1177,7 @@
 /*
  * called by SMT to calculate LEM bit error rate
  */
-void sm_lem_evaluate(smc)
-struct s_smc *smc ;
+void sm_lem_evaluate(struct s_smc *smc)
 {
 	int np ;
 
@@ -1219,9 +1185,7 @@
 		lem_evaluate(smc,&smc->y[np]) ;
 }
 
-static void lem_check_lct(smc,phy)
-struct s_smc *smc ;
-struct s_phy	*phy ;
+static void lem_check_lct(struct s_smc *smc, struct s_phy *phy)
 {
 	struct lem_counter	*lem = &phy->lem ;
 	struct fddi_mib_p	*mib ;
@@ -1265,10 +1229,7 @@
 /*
  * LEM functions
  */
-static void sm_ph_lem_start(smc,np,threshold)
-struct s_smc *smc ;
-int np;
-int threshold;
+static void sm_ph_lem_start(struct s_smc *smc, int np, int threshold)
 {
 	struct lem_counter *lem = &smc->y[np].lem ;
 
@@ -1286,9 +1247,7 @@
 	SETMASK(PLC(np,PL_INTR_MASK),PL_LE_CTR,PL_LE_CTR) ;
 }
 
-static void sm_ph_lem_stop(smc,np)
-struct s_smc *smc ;
-int np;
+static void sm_ph_lem_stop(struct s_smc *smc, int np)
 {
 	struct lem_counter *lem = &smc->y[np].lem ;
 
@@ -1297,10 +1256,8 @@
 }
 
 /* ARGSUSED */
-void sm_pm_ls_latch(smc,phy,on_off)
-struct s_smc *smc ;
-int phy;
-int on_off;		/* en- or disable ident. ls */
+void sm_pm_ls_latch(struct s_smc *smc, int phy, int on_off)
+/* int on_off;	en- or disable ident. ls */
 {
 	SK_UNUSED(smc) ;
 
@@ -1317,10 +1274,7 @@
 /*
  * PCM pseudo code 5.1 .. 6.1
  */
-static void pc_rcode_actions(smc,bit,phy)
-struct s_smc *smc ;
-int bit;
-struct s_phy *phy;
+static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
 {
 	struct fddi_mib_p	*mib ;
 
@@ -1456,10 +1410,7 @@
 /*
  * PCM pseudo code 5.1 .. 6.1
  */
-static void pc_tcode_actions(smc,bit,phy)
-struct s_smc *smc ;
-const int bit;
-struct s_phy *phy;
+static void pc_tcode_actions(struct s_smc *smc, const int bit, struct s_phy *phy)
 {
 	int	np = phy->np ;
 	struct fddi_mib_p	*mib ;
@@ -1638,8 +1589,7 @@
 /*
  * return status twisted (called by SMT)
  */
-int pcm_status_twisted(smc)
-struct s_smc *smc ;
+int pcm_status_twisted(struct s_smc *smc)
 {
 	int	twist = 0 ;
 	if (smc->s.sas != SMT_DAS)
@@ -1658,13 +1608,8 @@
  *	remote phy type
  *	remote mac yes/no
  */
-void pcm_status_state(smc,np,type,state,remote,mac)
-struct s_smc *smc ;
-int np;
-int *type;
-int *state;
-int *remote;
-int *mac;
+void pcm_status_state(struct s_smc *smc, int np, int *type, int *state,
+		      int *remote, int *mac)
 {
 	struct s_phy	*phy = &smc->y[np] ;
 	struct fddi_mib_p	*mib ;
@@ -1687,8 +1632,7 @@
 /*
  * return rooted station status (called by SMT)
  */
-int pcm_rooted_station(smc)
-struct s_smc *smc ;
+int pcm_rooted_station(struct s_smc *smc)
 {
 	int	n ;
 
@@ -1703,10 +1647,8 @@
 /*
  * Interrupt actions for PLC & PCM events
  */
-void plc_irq(smc,np,cmd)
-struct s_smc *smc ;
-int np;			/* PHY index */
-unsigned int cmd;
+void plc_irq(struct s_smc *smc, int np, unsigned int cmd)
+/* int np;	PHY index */
 {
 	struct s_phy *phy = &smc->y[np] ;
 	struct s_plc *plc = &phy->plc ;
@@ -1919,9 +1861,7 @@
 #endif
 }
 
-void pcm_set_lct_short(smc,n)
-struct s_smc *smc ;
-int n ;
+void pcm_set_lct_short(struct s_smc *smc, int n)
 {
 	if (n <= 0 || n > 1000)
 		return ;
@@ -1932,9 +1872,7 @@
 /*
  * fill state struct
  */
-void pcm_get_state(smc,state)
-struct s_smc *smc ;
-struct smt_state *state ;
+void pcm_get_state(struct s_smc *smc, struct smt_state *state)
 {
 	struct s_phy	*phy ;
 	struct pcm_state *pcs ;
@@ -1968,9 +1906,7 @@
 	}
 }
 
-int get_pcm_state(smc,np)
-struct s_smc *smc ;
-int np;
+int get_pcm_state(struct s_smc *smc, int np)
 {
 	int pcs ;
 
@@ -1992,9 +1928,7 @@
 	return(pcs) ;
 }
 
-char *get_linestate(smc,np)
-struct s_smc *smc ;
-int np;
+char *get_linestate(struct s_smc *smc, int np)
 {
 	char *ls = "" ;
 
@@ -2016,9 +1950,7 @@
 	return(ls) ;
 }
 
-char *get_pcmstate(smc,np)
-struct s_smc *smc ;
-int np;
+char *get_pcmstate(struct s_smc *smc, int np)
 {
 	char *pcs ;
 	
@@ -2040,8 +1972,7 @@
 	return(pcs) ;
 }
 
-void list_phy(smc)
-struct s_smc *smc ;
+void list_phy(struct s_smc *smc)
 {
 	struct s_plc *plc ;
 	int np ;
@@ -2069,8 +2000,7 @@
 
 
 #ifdef	CONCENTRATOR
-void pcm_lem_dump(smc)
-struct s_smc *smc ;
+void pcm_lem_dump(struct s_smc *smc)
 {
 	int		i ;
 	struct s_phy	*phy ;
diff -Nru a/drivers/net/skfp/pmf.c b/drivers/net/skfp/pmf.c
--- a/drivers/net/skfp/pmf.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/pmf.c	2004-06-17 14:49:49 -07:00
@@ -32,12 +32,16 @@
 static const char ID_sccs[] = "@(#)pmf.c	1.37 97/08/04 (C) SK " ;
 #endif
 
-static int smt_authorize() ;
-static int smt_check_set_count() ;
-static const struct s_p_tab *smt_get_ptab() ;
-static int smt_mib_phys() ;
-int smt_set_para() ;
-void smt_add_para() ;
+static int smt_authorize(struct s_smc *smc, struct smt_header *sm);
+static int smt_check_set_count(struct s_smc *smc, struct smt_header *sm);
+static const struct s_p_tab* smt_get_ptab(u_short para);
+static int smt_mib_phys(struct s_smc *smc);
+int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index, int local,
+		 int set);
+void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
+		  int index, int local);
+static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
+				     int set, int local);
 
 #define MOFFSS(e)	((int)&(((struct fddi_mib *)0)->e))
 #define MOFFSA(e)	((int) (((struct fddi_mib *)0)->e))
@@ -280,13 +284,7 @@
 	{ 0 }
 } ;
 
-
-static SMbuf *smt_build_pmf_response() ;
-
-void smt_pmf_received_pack(smc,mb,local)
-struct s_smc *smc ;
-SMbuf *mb ;
-int local ;
+void smt_pmf_received_pack(struct s_smc *smc, SMbuf *mb, int local)
 {
 	struct smt_header	*sm ;
 	SMbuf		*reply ;
@@ -316,13 +314,8 @@
 	}
 }
 
-extern	SMbuf	*smt_get_mbuf() ;
-
-static SMbuf *smt_build_pmf_response(smc,req,set,local)
-struct s_smc *smc ;
-struct smt_header *req ;
-int	set ;
-int	local ;
+static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
+				     int set, int local)
 {
 	SMbuf			*mb ;
 	struct smt_header	*smt ;
@@ -509,11 +502,7 @@
 	return(mb) ;
 }
 
-extern void *sm_to_para() ;
-
-static int smt_authorize(smc,sm)
-struct s_smc *smc ;
-struct smt_header *sm ;
+static int smt_authorize(struct s_smc *smc, struct smt_header *sm)
 {
 	struct smt_para	*pa ;
 	int		i ;
@@ -548,9 +537,7 @@
 	return(0) ;
 }
 
-static int smt_check_set_count(smc,sm)
-struct s_smc *smc ;
-struct smt_header *sm ;
+static int smt_check_set_count(struct s_smc *smc, struct smt_header *sm)
 {
 	struct smt_para	*pa ;
 	struct smt_p_setcount	*sc ;
@@ -566,12 +553,8 @@
 	return(0) ;
 }
 
-void smt_add_para(smc,pcon,para,index,local)
-struct s_smc *smc ;
-struct s_pcon *pcon ;
-u_short para ;
-int index ;
-int local ;
+void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
+		  int index, int local)
 {
 	struct smt_para	*pa ;
 	const struct s_p_tab	*pt ;
@@ -1095,12 +1078,8 @@
 /*
  * set parameter
  */
-int smt_set_para(smc,pa,index,local,set)
-struct s_smc *smc ;
-struct smt_para	*pa ;
-int index ;
-int local ;
-int set ;
+int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index, int local,
+		 int set)
 {
 #define IFSET(x)	if (set) (x)
 
@@ -1549,8 +1528,7 @@
 #endif
 }
 
-static const struct s_p_tab *smt_get_ptab(para)
-u_short para ;
+static const struct s_p_tab *smt_get_ptab(u_short para)
 {
 	const struct s_p_tab	*pt ;
 	for (pt = p_tab ; pt->p_num && pt->p_num != para ; pt++)
@@ -1558,8 +1536,7 @@
 	return(pt->p_num ? pt : 0) ;
 }
 
-static int smt_mib_phys(smc)
-struct s_smc *smc ;
+static int smt_mib_phys(struct s_smc *smc)
 {
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
@@ -1572,9 +1549,7 @@
 #endif
 }
 
-int port_to_mib(smc,p)
-struct s_smc *smc ;
-int p ;
+int port_to_mib(struct s_smc *smc, int p)
 {
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
@@ -1590,10 +1565,7 @@
 
 #ifdef	DEBUG
 #ifndef	BOOT
-void dump_smt(smc,sm,text)
-struct s_smc *smc ;
-struct smt_header *sm ;
-char *text ;
+void dump_smt(struct s_smc *smc, struct smt_header *sm, char *text)
 {
 	int	len ;
 	struct smt_para	*pa ;
@@ -1680,9 +1652,7 @@
 	printf("-------------------------------------------------\n\n") ;
 }
 
-void dump_hex(p,len)
-char *p ;
-int len ;
+void dump_hex(char *p, int len)
 {
 	int	n = 0 ;
 	while (len--) {
diff -Nru a/drivers/net/skfp/queue.c b/drivers/net/skfp/queue.c
--- a/drivers/net/skfp/queue.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/queue.c	2004-06-17 14:49:49 -07:00
@@ -31,8 +31,7 @@
 /*
  * init event queue management
  */
-void ev_init(smc)
-struct s_smc *smc ;
+void ev_init(struct s_smc *smc)
 {
 	smc->q.ev_put = smc->q.ev_get = smc->q.ev_queue ;
 }
@@ -40,10 +39,7 @@
 /*
  * add event to queue
  */
-void queue_event(smc,class,event)
-struct s_smc *smc ;
-int class ;
-int event ;
+void queue_event(struct s_smc *smc, int class, int event)
 {
 	PRINTF("queue class %d event %d\n",class,event) ;
 	smc->q.ev_put->class = class ;
@@ -59,9 +55,7 @@
 /*
  * timer_event is called from HW timer package.
  */
-void timer_event(smc,token)
-struct s_smc *smc ;
-u_long token ;
+void timer_event(struct s_smc *smc, u_long token)
 {
 	PRINTF("timer event class %d token %d\n",
 		EV_T_CLASS(token),
@@ -76,8 +70,7 @@
  *		send command to state machine
  *	end
  */
-void ev_dispatcher(smc)
-struct s_smc *smc ;
+void ev_dispatcher(struct s_smc *smc)
 {
 	struct event_queue *ev ;	/* pointer into queue */
 	int		class ;
@@ -131,9 +124,7 @@
  *	on	0	disconnect
  *	on	1	connect
  */
-u_short smt_online(smc,on)
-struct s_smc *smc ;
-int on ;
+u_short smt_online(struct s_smc *smc, int on)
 {
 	queue_event(smc,EVENT_ECM,on ? EC_CONNECT : EC_DISCONNECT) ;
 	ev_dispatcher(smc) ;
@@ -147,10 +138,7 @@
  * dump current flag setting
  */
 #ifdef	CONCENTRATOR
-void do_smt_flag(smc,flag,value)
-struct s_smc *smc ;
-char *flag ;
-int value ;
+void do_smt_flag(struct s_smc *smc, char *flag, int value)
 {
 #ifdef	DEBUG
 	struct smt_debug	*deb;
diff -Nru a/drivers/net/skfp/rmt.c b/drivers/net/skfp/rmt.c
--- a/drivers/net/skfp/rmt.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/rmt.c	2004-06-17 14:49:49 -07:00
@@ -102,17 +102,17 @@
 /*
  * function declarations
  */
-static void rmt_fsm() ;
-static void start_rmt_timer0() ;
-static void start_rmt_timer1() ;
-static void start_rmt_timer2() ;
-static void stop_rmt_timer0() ;
-static void stop_rmt_timer1() ;
-static void stop_rmt_timer2() ;
-static void rmt_dup_actions() ;
-static void rmt_reinsert_actions() ;
-static void rmt_leave_actions() ;
-static void rmt_new_dup_actions() ;
+static void rmt_fsm(struct s_smc *smc, int cmd);
+static void start_rmt_timer0(struct s_smc *smc, u_long value, int event);
+static void start_rmt_timer1(struct s_smc *smc, u_long value, int event);
+static void start_rmt_timer2(struct s_smc *smc, u_long value, int event);
+static void stop_rmt_timer0(struct s_smc *smc);
+static void stop_rmt_timer1(struct s_smc *smc);
+static void stop_rmt_timer2(struct s_smc *smc);
+static void rmt_dup_actions(struct s_smc *smc);
+static void rmt_reinsert_actions(struct s_smc *smc);
+static void rmt_leave_actions(struct s_smc *smc);
+static void rmt_new_dup_actions(struct s_smc *smc);
 
 #ifndef SUPERNET_3
 extern void restart_trt_for_dbcn() ;
@@ -122,8 +122,7 @@
 	init RMT state machine
 	clear all RMT vars and flags
 */
-void rmt_init(smc)
-struct s_smc *smc ;
+void rmt_init(struct s_smc *smc)
 {
 	smc->mib.m[MAC0].fddiMACRMTState = ACTIONS(RM0_ISOLATED) ;
 	smc->r.dup_addr_test = DA_NONE ;
@@ -145,9 +144,7 @@
 		process event
 	until SM is stable
 */
-void rmt(smc,event)
-struct s_smc *smc ;
-int event ;
+void rmt(struct s_smc *smc, int event)
 {
 	int	state ;
 
@@ -166,9 +163,7 @@
 /*
 	process RMT event
 */
-static void rmt_fsm(smc,cmd)
-struct s_smc *smc ;
-int cmd ;
+static void rmt_fsm(struct s_smc *smc, int cmd)
 {
 	/*
 	 * RM00-RM70 : from all states
@@ -535,8 +530,7 @@
  * (jd) RMT duplicate address actions
  * leave the ring or reinsert just as configured
  */
-static void rmt_dup_actions(smc)
-struct s_smc *smc ;
+static void rmt_dup_actions(struct s_smc *smc)
 {
 	if (smc->r.jm_flag) {
 	}
@@ -555,8 +549,7 @@
 /*
  * Reconnect to the Ring
  */
-static void rmt_reinsert_actions(smc)
-struct s_smc *smc ;
+static void rmt_reinsert_actions(struct s_smc *smc)
 {
 	queue_event(smc,EVENT_ECM,EC_DISCONNECT) ;
 	queue_event(smc,EVENT_ECM,EC_CONNECT) ;
@@ -565,8 +558,7 @@
 /*
  * duplicate address detected
  */
-static void rmt_new_dup_actions(smc)
-struct s_smc *smc ;
+static void rmt_new_dup_actions(struct s_smc *smc)
 {
 	smc->r.da_flag = TRUE ;
 	smc->r.bn_flag = FALSE ;
@@ -591,8 +583,7 @@
 /*
  * leave the ring
  */
-static void rmt_leave_actions(smc)
-struct s_smc *smc ;
+static void rmt_leave_actions(struct s_smc *smc)
 {
 	queue_event(smc,EVENT_ECM,EC_DISCONNECT) ;
 	/*
@@ -605,10 +596,7 @@
  * SMT timer interface
  *	start RMT timer 0
  */
-static void start_rmt_timer0(smc,value,event)
-struct s_smc *smc ;
-u_long value ;
-int event ;
+static void start_rmt_timer0(struct s_smc *smc, u_long value, int event)
 {
 	smc->r.timer0_exp = FALSE ;		/* clear timer event flag */
 	smt_timer_start(smc,&smc->r.rmt_timer0,value,EV_TOKEN(EVENT_RMT,event));
@@ -618,10 +606,7 @@
  * SMT timer interface
  *	start RMT timer 1
  */
-static void start_rmt_timer1(smc,value,event)
-struct s_smc *smc ;
-u_long value ;
-int event ;
+static void start_rmt_timer1(struct s_smc *smc, u_long value, int event)
 {
 	smc->r.timer1_exp = FALSE ;	/* clear timer event flag */
 	smt_timer_start(smc,&smc->r.rmt_timer1,value,EV_TOKEN(EVENT_RMT,event));
@@ -631,10 +616,7 @@
  * SMT timer interface
  *	start RMT timer 2
  */
-static void start_rmt_timer2(smc,value,event)
-struct s_smc *smc ;
-u_long value ;
-int event ;
+static void start_rmt_timer2(struct s_smc *smc, u_long value, int event)
 {
 	smc->r.timer2_exp = FALSE ;		/* clear timer event flag */
 	smt_timer_start(smc,&smc->r.rmt_timer2,value,EV_TOKEN(EVENT_RMT,event));
@@ -644,8 +626,7 @@
  * SMT timer interface
  *	stop RMT timer 0
  */
-static void stop_rmt_timer0(smc)
-struct s_smc *smc ;
+static void stop_rmt_timer0(struct s_smc *smc)
 {
 	if (smc->r.rmt_timer0.tm_active)
 		smt_timer_stop(smc,&smc->r.rmt_timer0) ;
@@ -655,8 +636,7 @@
  * SMT timer interface
  *	stop RMT timer 1
  */
-static void stop_rmt_timer1(smc)
-struct s_smc *smc ;
+static void stop_rmt_timer1(struct s_smc *smc)
 {
 	if (smc->r.rmt_timer1.tm_active)
 		smt_timer_stop(smc,&smc->r.rmt_timer1) ;
@@ -666,9 +646,9 @@
  * SMT timer interface
  *	stop RMT timer 2
  */
-static void stop_rmt_timer2(smc)
-struct s_smc *smc ;
+static void stop_rmt_timer2(struct s_smc *smc)
 {
 	if (smc->r.rmt_timer2.tm_active)
 		smt_timer_stop(smc,&smc->r.rmt_timer2) ;
 }
+
diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/skfddi.c	2004-06-17 14:49:49 -07:00
@@ -131,20 +131,10 @@
 		       int frag_count);
 int mac_drv_rx_init(struct s_smc *smc, int len, int fc, char *look_ahead,
 		    int la_len);
-void smt_timer_poll(struct s_smc *smc);
-void ring_status_indication(struct s_smc *smc, u_long status);
-unsigned long smt_get_time(void);
-void smt_stat_counter(struct s_smc *smc, int stat);
-void cfm_state_change(struct s_smc *smc, int c_state);
-void ecm_state_change(struct s_smc *smc, int e_state);
-void pcm_state_change(struct s_smc *smc, int plc, int p_state);
-void rmt_state_change(struct s_smc *smc, int r_state);
-void drv_reset_indication(struct s_smc *smc);
 void dump_data(unsigned char *Data, int length);
 
-
 // External functions from the hardware module
-extern u_int mac_drv_check_space();
+extern u_int mac_drv_check_space(void);
 extern void read_address(struct s_smc *smc, u_char * mac_addr);
 extern void card_stop(struct s_smc *smc);
 extern int mac_drv_init(struct s_smc *smc);
@@ -157,9 +147,7 @@
 extern void hwm_rx_frag(struct s_smc *smc, char far * virt, u_long phys,
 			int len, int frame_status);
 extern void mac_drv_rx_mode(struct s_smc *smc, int mode);
-extern void mac_drv_clear_tx_queue(struct s_smc *smc);
 extern void mac_drv_clear_rx_queue(struct s_smc *smc);
-extern void mac_clear_multicast(struct s_smc *smc);
 extern void enable_tx_irq(struct s_smc *smc, u_short queue);
 extern void mac_drv_clear_txd(struct s_smc *smc);
 
@@ -921,8 +909,7 @@
 				dmi = dev->mc_list;
 
 				for (i = 0; i < dev->mc_count; i++) {
-					mac_add_multicast(smc,
-							  dmi->dmi_addr, 1);
+					mac_add_multicast(smc, dmi->dmi_addr, 1);
 					PRINTK(KERN_INFO "ENABLE MC ADDRESS:");
 					PRINTK(" %02x %02x %02x ",
 					       dmi->dmi_addr[0],
diff -Nru a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
--- a/drivers/net/skfp/smt.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/smt.c	2004-06-17 14:49:49 -07:00
@@ -62,68 +62,63 @@
 /*
  * external functions
  */
-int pcm_status_twisted() ;
-void pcm_status_state() ;
-int pcm_status_type() ;
+int pcm_status_twisted(struct s_smc *smc);
 
-extern SMbuf *smt_get_mbuf() ;
-
-#define EXPORT_PMF
 /*
  * function prototypes
  */
-u_long smt_get_tid() ;
-EXPORT_PMF SMbuf *smt_build_frame() ;
-EXPORT_PMF void *sm_to_para() ;
 #ifdef	LITTLE_ENDIAN
-static int smt_swap_short() ;
+static int smt_swap_short(u_short s);
 #endif
-static int mac_index() ;
-static int phy_index() ;
-static int mac_con_resource_index() ;
-static int phy_con_resource_index() ;
-EXPORT_PMF void smt_send_frame() ;
-EXPORT_PMF void smt_set_timestamp() ;
-static void smt_send_rdf() ;
-static void smt_send_nif() ;
-static void smt_send_ecf() ;
-static void smt_echo_test() ;
-static void smt_send_sif_config() ;
-static void smt_send_sif_operation() ;
-EXPORT_PMF void smt_swap_para() ;
+static int mac_index(struct s_smc *smc, int mac);
+static int phy_index(struct s_smc *smc, int phy);
+static int mac_con_resource_index(struct s_smc *smc, int mac);
+static int phy_con_resource_index(struct s_smc *smc, int phy);
+static void smt_send_rdf(struct s_smc *smc, SMbuf *rej, int fc, int reason,
+			 int local);
+static void smt_send_nif(struct s_smc *smc, struct fddi_addr *dest, int fc,
+			 u_long tid, int type, int local);
+static void smt_send_ecf(struct s_smc *smc, struct fddi_addr *dest, int fc,
+                         u_long tid, int type, int len);
+static void smt_echo_test(struct s_smc *smc, int dna);
+static void smt_send_sif_config(struct s_smc *smc, struct fddi_addr *dest,
+				u_long tid, int local);
+static void smt_send_sif_operation(struct s_smc *smc, struct fddi_addr *dest,
+				   u_long tid, int local);
 #ifdef LITTLE_ENDIAN
-static void smt_string_swap() ;
+static void smt_string_swap(void);
 #endif
-static void smt_add_frame_len() ;
-static void smt_fill_una() ;
-static void smt_fill_sde() ;
-static void smt_fill_state() ;
-static void smt_fill_timestamp() ;
-static void smt_fill_policy() ;
-static void smt_fill_latency() ;
-static void smt_fill_neighbor() ;
-static int  smt_fill_path() ;
-static void smt_fill_mac_status() ;
-static void smt_fill_lem() ;
-static void smt_fill_version() ;
-static void smt_fill_fsc() ;
-static void smt_fill_mac_counter() ;
-static void smt_fill_mac_fnc() ;
-static void smt_fill_manufacturer() ;
-static void smt_fill_user() ;
-static void smt_fill_setcount() ;
-static void smt_fill_echo() ;
-int smt_check_para() ;
+static void smt_add_frame_len(SMbuf *mb, int len);
+static void smt_fill_una(struct s_smc *smc, struct smt_p_una *una);
+static void smt_fill_sde(struct s_smc *smc, struct smt_p_sde *sde);
+static void smt_fill_state(struct s_smc *smc, struct smt_p_state *state);
+static void smt_fill_timestamp(struct s_smc *smc, struct smt_p_timestamp *ts);
+static void smt_fill_policy(struct s_smc *smc, struct smt_p_policy *policy);
+static void smt_fill_latency(struct s_smc *smc, struct smt_p_latency *latency);
+static void smt_fill_neighbor(struct s_smc *smc, struct smt_p_neighbor *neighbor);
+static int smt_fill_path(struct s_smc *smc, struct smt_p_path *path);
+static void smt_fill_mac_status(struct s_smc *smc, struct smt_p_mac_status *st);
+static void smt_fill_lem(struct s_smc *smc, struct smt_p_lem *lem, int phy);
+static void smt_fill_version(struct s_smc *smc, struct smt_p_version *vers);
+static void smt_fill_fsc(struct s_smc *smc, struct smt_p_fsc *fsc);
+static void smt_fill_mac_counter(struct s_smc *smc, struct smt_p_mac_counter *mc);
+static void smt_fill_mac_fnc(struct s_smc *smc, struct smt_p_mac_fnc *fnc);
+static void smt_fill_manufacturer(struct s_smc *smc, 
+				  struct smp_p_manufacturer *man);
+static void smt_fill_user(struct s_smc *smc, struct smp_p_user *user);
+static void smt_fill_setcount(struct s_smc *smc, struct smt_p_setcount *setcount);
+static void smt_fill_echo(struct s_smc *smc, struct smt_p_echo *echo, u_long seed,
+			  int len);
 
-void smt_clear_una_dna() ;
-static void smt_clear_old_una_dna() ;
+void smt_clear_una_dna(struct s_smc *smc);
+static void smt_clear_old_una_dna(struct s_smc *smc);
 #ifdef	CONCENTRATOR
-static int entity_to_index() ;
+static int entity_to_index(void);
 #endif
-static void update_dac() ;
-static int div_ratio() ;
+static void update_dac(struct s_smc *smc, int report);
+static int div_ratio(u_long upper, u_long lower);
 #ifdef  USE_CAN_ADDR
-void	hwm_conv_can() ;
+void	hwm_conv_can(struct s_smc *smc, char *data, int len);
 #else
 #define		hwm_conv_can(smc,data,len)
 #endif
@@ -136,8 +131,7 @@
 /*
  * init SMT agent
  */
-void smt_agent_init(smc)
-struct s_smc *smc ;
+void smt_agent_init(struct s_smc *smc)
 {
 	int		i ;
 
@@ -183,17 +177,16 @@
  *	check tvu & tvd
  * end
  */
-void smt_agent_task(smc)
-struct s_smc *smc ;
+void smt_agent_task(struct s_smc *smc)
 {
 	smt_timer_start(smc,&smc->sm.smt_timer, (u_long)1000000L,
 		EV_TOKEN(EVENT_SMT,SM_TIMER)) ;
 	DB_SMT("SMT agent task\n",0,0) ;
 }
 
-void smt_please_reconnect(smc,reconn_time)
-struct s_smc	*smc ;		/* Pointer to SMT context */
-int		reconn_time ;	/* Wait for reconnect time in seconds */
+void smt_please_reconnect(struct s_smc *smc, int reconn_time)
+/* struct s_smc	*smc;  Pointer to SMT context */
+/* int reconn_time;    Wait for reconnect time in seconds */
 {
 	/*
 	 * The please reconnect variable is used as a timer.
@@ -210,9 +203,7 @@
 }
 
 #ifndef SMT_REAL_TOKEN_CT
-void smt_emulate_token_ct(smc, mac_index)
-struct s_smc	*smc;
-int		mac_index;
+void smt_emulate_token_ct(struct s_smc *smc, int mac_index)
 {
 	u_long	count;
 	u_long	time;
@@ -239,9 +230,7 @@
 #endif
 
 /*ARGSUSED1*/
-void smt_event(smc,event)
-struct s_smc *smc ;
-int event ;
+void smt_event(struct s_smc *smc, int event)
 {
 	u_long		time ;
 #ifndef SMT_REAL_TOKEN_CT
@@ -457,9 +446,7 @@
 		EV_TOKEN(EVENT_SMT,SM_TIMER)) ;
 }
 
-static int div_ratio(upper,lower)
-u_long upper ;
-u_long lower ;
+static int div_ratio(u_long upper, u_long lower)
 {
 	if ((upper<<16L) < upper)
 		upper = 0xffff0000L ;
@@ -475,10 +462,8 @@
 /*
  * receive packet handler
  */
-void smt_received_pack(smc,mb,fs)
-struct s_smc *smc ;
-SMbuf *mb ;
-int fs ;			/* frame status */
+void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
+/* int fs;  frame status */
 {
 	struct smt_header	*sm ;
 	int			local ;
@@ -823,9 +808,7 @@
 	smt_free_mbuf(smc,mb) ;
 }
 
-static void update_dac(smc,report)
-struct s_smc *smc ;
-int report ;
+static void update_dac(struct s_smc *smc, int report)
 {
 	int	cond ;
 
@@ -843,11 +826,9 @@
  *	set station ID
  *	send frame
  */
-EXPORT_PMF void smt_send_frame(smc,mb,fc,local)
-struct s_smc *smc ;
-SMbuf *mb ;			/* buffer to send */
-int fc ;			/* FC value */
-int local ;
+void smt_send_frame(struct s_smc *smc, SMbuf *mb, int fc, int local)
+/* SMbuf *mb;	buffer to send */
+/* int fc;	FC value */
 {
 	struct smt_header	*sm ;
 
@@ -868,12 +849,11 @@
 /*
  * generate and send RDF
  */
-static void smt_send_rdf(smc,rej,fc,reason,local)
-struct s_smc *smc ;
-SMbuf	*rej ;			/* mbuf of offending frame */
-int	fc ;			/* FC of denied frame */
-int reason ;			/* reason code */
-int local ;
+static void smt_send_rdf(struct s_smc *smc, SMbuf *rej, int fc, int reason,
+			 int local)
+/* SMbuf *rej;	mbuf of offending frame */
+/* int fc;	FC of denied frame */
+/* int reason;	reason code */
 {
 	SMbuf	*mb ;
 	struct smt_header	*sm ;	/* header of offending frame */
@@ -946,13 +926,12 @@
 /*
  * generate and send NIF
  */
-static void smt_send_nif(smc,dest,fc,tid,type,local)
-struct s_smc *smc ;
-struct fddi_addr *dest ;		/* dest address */
-int fc ;				/* frame control */
-u_long tid ;				/* transaction id */
-int type ;				/* frame type */
-int local ;
+static void smt_send_nif(struct s_smc *smc, struct fddi_addr *dest, int fc,
+			 u_long tid, int type, int local)
+/* struct fddi_addr *dest;	dest address */
+/* int fc;			frame control */
+/* u_long tid;			transaction id */
+/* int type;			frame type */
 {
 	struct smt_nif	*nif ;
 	SMbuf		*mb ;
@@ -976,9 +955,7 @@
 /*
  * send NIF request (test purpose)
  */
-static void smt_send_nif_request(smc,dest)
-struct s_smc *smc ;
-struct fddi_addr *dest ;
+static void smt_send_nif_request(struct s_smc *smc, struct fddi_addr *dest)
 {
 	smc->sm.pend[SMT_TID_NIF_TEST] = smt_get_tid(smc) ;
 	smt_send_nif(smc,dest, FC_SMT_INFO, smc->sm.pend[SMT_TID_NIF_TEST],
@@ -988,10 +965,8 @@
 /*
  * send ECF request (test purpose)
  */
-static void smt_send_ecf_request(smc,dest,len)
-struct s_smc *smc ;
-struct fddi_addr *dest ;
-int len ;
+static void smt_send_ecf_request(struct s_smc *smc, struct fddi_addr *dest,
+				 int len)
 {
 	smc->sm.pend[SMT_TID_ECF] = smt_get_tid(smc) ;
 	smt_send_ecf(smc,dest, FC_SMT_INFO, smc->sm.pend[SMT_TID_ECF],
@@ -1002,9 +977,7 @@
 /*
  * echo test
  */
-static void smt_echo_test(smc,dna)
-struct s_smc *smc ;
-int dna ;
+static void smt_echo_test(struct s_smc *smc, int dna)
 {
 	u_long	tid ;
 
@@ -1019,13 +992,13 @@
 /*
  * generate and send ECF
  */
-static void smt_send_ecf(smc,dest,fc,tid,type,len)
-struct s_smc *smc ;
-struct fddi_addr *dest ;		/* dest address */
-int fc ;				/* frame control */
-u_long tid ;				/* transaction id */
-int type ;				/* frame type */
-int len ;				/* frame length */
+static void smt_send_ecf(struct s_smc *smc, struct fddi_addr *dest, int fc,
+			 u_long tid, int type, int len)
+/* struct fddi_addr *dest;	dest address */
+/* int fc;			frame control */
+/* u_long tid;			transaction id */
+/* int type;			frame type */
+/* int len;			frame length */
 {
 	struct smt_ecf	*ecf ;
 	SMbuf		*mb ;
@@ -1045,11 +1018,10 @@
  * generate and send SIF config response
  */
 
-static void smt_send_sif_config(smc,dest,tid,local)
-struct s_smc *smc ;
-struct fddi_addr *dest ;		/* dest address */
-u_long tid ;				/* transaction id */
-int local ;
+static void smt_send_sif_config(struct s_smc *smc, struct fddi_addr *dest,
+				u_long tid, int local)
+/* struct fddi_addr *dest;	dest address */
+/* u_long tid;			transaction id */
 {
 	struct smt_sif_config	*sif ;
 	SMbuf			*mb ;
@@ -1079,11 +1051,10 @@
  * generate and send SIF operation response
  */
 
-static void smt_send_sif_operation(smc,dest,tid,local)
-struct s_smc *smc ;
-struct fddi_addr *dest ;		/* dest address */
-u_long tid ;				/* transaction id */
-int local ;
+static void smt_send_sif_operation(struct s_smc *smc, struct fddi_addr *dest,
+				   u_long tid, int local)
+/* struct fddi_addr *dest;	dest address */
+/* u_long tid;			transaction id */
 {
 	struct smt_sif_operation *sif ;
 	SMbuf			*mb ;
@@ -1128,11 +1099,8 @@
 /*
  * get and initialize SMT frame
  */
-EXPORT_PMF SMbuf *smt_build_frame(smc,class,type,length)
-struct s_smc *smc ;
-int class ;
-int type ;
-int length ;
+SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
+				  int length)
 {
 	SMbuf			*mb ;
 	struct smt_header	*smt ;
@@ -1167,9 +1135,7 @@
 	return(mb) ;
 }
 
-static void smt_add_frame_len(mb,len)
-SMbuf *mb ;
-int len ;
+static void smt_add_frame_len(SMbuf *mb, int len)
 {
 	struct smt_header	*smt ;
 
@@ -1183,9 +1149,7 @@
 /*
  * fill values in UNA parameter
  */
-static void smt_fill_una(smc,una)
-struct s_smc *smc ;
-struct smt_p_una *una ;
+static void smt_fill_una(struct s_smc *smc, struct smt_p_una *una)
 {
 	SMTSETPARA(una,SMT_P_UNA) ;
 	una->una_pad = 0 ;
@@ -1195,9 +1159,7 @@
 /*
  * fill values in SDE parameter
  */
-static void smt_fill_sde(smc,sde)
-struct s_smc *smc ;
-struct smt_p_sde *sde ;
+static void smt_fill_sde(struct s_smc *smc, struct smt_p_sde *sde)
 {
 	SMTSETPARA(sde,SMT_P_SDE) ;
 	sde->sde_non_master = smc->mib.fddiSMTNonMaster_Ct ;
@@ -1213,9 +1175,7 @@
 /*
  * fill in values in station state parameter
  */
-static void smt_fill_state(smc,state)
-struct s_smc *smc ;
-struct smt_p_state *state ;
+static void smt_fill_state(struct s_smc *smc, struct smt_p_state *state)
 {
 	int	top ;
 	int	twist ;
@@ -1255,18 +1215,14 @@
 /*
  * fill values in timestamp parameter
  */
-static void smt_fill_timestamp(smc,ts)
-struct s_smc *smc ;
-struct smt_p_timestamp *ts ;
+static void smt_fill_timestamp(struct s_smc *smc, struct smt_p_timestamp *ts)
 {
 
 	SMTSETPARA(ts,SMT_P_TIMESTAMP) ;
 	smt_set_timestamp(smc,ts->ts_time) ;
 }
 
-EXPORT_PMF void smt_set_timestamp(smc,p)
-struct s_smc *smc ;
-u_char *p ;
+void smt_set_timestamp(struct s_smc *smc, u_char *p)
 {
 	u_long	time ;
 	u_long	utime ;
@@ -1300,9 +1256,7 @@
 /*
  * fill values in station policy parameter
  */
-static void smt_fill_policy(smc,policy)
-struct s_smc *smc ;
-struct smt_p_policy *policy ;
+static void smt_fill_policy(struct s_smc *smc, struct smt_p_policy *policy)
 {
 	int	i ;
 	u_char	*map ;
@@ -1333,9 +1287,7 @@
 /*
  * fill values in latency equivalent parameter
  */
-static void smt_fill_latency(smc,latency)
-struct s_smc *smc ;
-struct smt_p_latency *latency ;
+static void smt_fill_latency(struct s_smc *smc, struct smt_p_latency *latency)
 {
 	SMTSETPARA(latency,SMT_P_LATENCY) ;
 
@@ -1358,9 +1310,7 @@
 /*
  * fill values in MAC neighbors parameter
  */
-static void smt_fill_neighbor(smc,neighbor)
-struct s_smc *smc ;
-struct smt_p_neighbor *neighbor ;
+static void smt_fill_neighbor(struct s_smc *smc, struct smt_p_neighbor *neighbor)
 {
 	SMTSETPARA(neighbor,SMT_P_NEIGHBORS) ;
 
@@ -1379,9 +1329,7 @@
 #define ALLPHYS	((smc->s.sas == SMT_SAS) ? 1 : 2)
 #endif
 
-static int smt_fill_path(smc,path)
-struct s_smc *smc ;
-struct smt_p_path *path ;
+static int smt_fill_path(struct s_smc *smc, struct smt_p_path *path)
 {
 	SK_LOC_DECL(int,type) ;
 	SK_LOC_DECL(int,state) ;
@@ -1429,9 +1377,7 @@
 /*
  * fill values in mac status
  */
-static void smt_fill_mac_status(smc,st)
-struct s_smc *smc ;
-struct smt_p_mac_status *st ;
+static void smt_fill_mac_status(struct s_smc *smc, struct smt_p_mac_status *st)
 {
 	SMTSETPARA(st,SMT_P_MAC_STATUS) ;
 
@@ -1458,11 +1404,7 @@
 /*
  * fill values in LEM status
  */
-
-static void smt_fill_lem(smc,lem,phy)
-struct s_smc *smc ;
-struct smt_p_lem *lem ;
-int phy ;
+static void smt_fill_lem(struct s_smc *smc, struct smt_p_lem *lem, int phy)
 {
 	struct fddi_mib_p	*mib ;
 
@@ -1484,9 +1426,7 @@
 /*
  * fill version parameter
  */
-static void smt_fill_version(smc,vers)
-struct s_smc *smc ;
-struct smt_p_version *vers ;
+static void smt_fill_version(struct s_smc *smc, struct smt_p_version *vers)
 {
 	SK_UNUSED(smc) ;
 	SMTSETPARA(vers,SMT_P_VERSION) ;
@@ -1505,9 +1445,7 @@
  * note: this para 200B is NOT in swap table, because it's also set in
  * PMF add_para
  */
-static void smt_fill_fsc(smc,fsc)
-struct s_smc *smc ;
-struct smt_p_fsc *fsc ;
+static void smt_fill_fsc(struct s_smc *smc, struct smt_p_fsc *fsc)
 {
 	SK_UNUSED(smc) ;
 	SMTSETPARA(fsc,SMT_P_FSC) ;
@@ -1527,9 +1465,7 @@
 /*
  * fill mac counter field
  */
-static void smt_fill_mac_counter(smc,mc)
-struct s_smc *smc ;
-struct smt_p_mac_counter *mc ;
+static void smt_fill_mac_counter(struct s_smc *smc, struct smt_p_mac_counter *mc)
 {
 	SMTSETPARA(mc,SMT_P_MAC_COUNTER) ;
 	mc->mc_mib_index = INDEX_MAC ;
@@ -1541,9 +1477,7 @@
 /*
  * fill mac frame not copied counter
  */
-static void smt_fill_mac_fnc(smc,fnc)
-struct s_smc *smc ;
-struct smt_p_mac_fnc *fnc ;
+static void smt_fill_mac_fnc(struct s_smc *smc, struct smt_p_mac_fnc *fnc)
 {
 	SMTSETPARA(fnc,SMT_P_MAC_FNC) ;
 	fnc->nc_mib_index = INDEX_MAC ;
@@ -1555,9 +1489,8 @@
 /*
  * fill manufacturer field
  */
-static void smt_fill_manufacturer(smc,man)
-struct s_smc *smc ;
-struct smp_p_manufacturer *man ;
+static void smt_fill_manufacturer(struct s_smc *smc, 
+				  struct smp_p_manufacturer *man)
 {
 	SMTSETPARA(man,SMT_P_MANUFACTURER) ;
 	memcpy((char *) man->mf_data,
@@ -1568,9 +1501,7 @@
 /*
  * fill user field
  */
-static void smt_fill_user(smc,user)
-struct s_smc *smc ;
-struct smp_p_user *user ;
+static void smt_fill_user(struct s_smc *smc, struct smp_p_user *user)
 {
 	SMTSETPARA(user,SMT_P_USER) ;
 	memcpy((char *) user->us_data,
@@ -1578,14 +1509,10 @@
 		sizeof(user->us_data)) ;
 }
 
-
-
 /*
  * fill set count
  */
-static void smt_fill_setcount(smc,setcount)
-struct s_smc *smc ;
-struct smt_p_setcount *setcount ;
+static void smt_fill_setcount(struct s_smc *smc, struct smt_p_setcount *setcount)
 {
 	SK_UNUSED(smc) ;
 	SMTSETPARA(setcount,SMT_P_SETCOUNT) ;
@@ -1597,13 +1524,9 @@
 /*
  * fill echo data
  */
-static void smt_fill_echo(smc,echo,seed,len)
-struct s_smc *smc ;
-struct smt_p_echo *echo ;
-u_long seed ;
-int len ;
+static void smt_fill_echo(struct s_smc *smc, struct smt_p_echo *echo, u_long seed,
+			  int len)
 {
-
 	u_char	*p ;
 
 	SK_UNUSED(smc) ;
@@ -1619,22 +1542,19 @@
  * clear DNA and UNA
  * called from CFM if configuration changes
  */
-void smt_clear_una_dna(smc)
-struct s_smc *smc ;
+void smt_clear_una_dna(struct s_smc *smc)
 {
 	smc->mib.m[MAC0].fddiMACUpstreamNbr = SMT_Unknown ;
 	smc->mib.m[MAC0].fddiMACDownstreamNbr = SMT_Unknown ;
 }
 
-static void smt_clear_old_una_dna(smc)
-struct s_smc *smc ;
+static void smt_clear_old_una_dna(struct s_smc *smc)
 {
 	smc->mib.m[MAC0].fddiMACOldUpstreamNbr = SMT_Unknown ;
 	smc->mib.m[MAC0].fddiMACOldDownstreamNbr = SMT_Unknown ;
 }
 
-u_long smt_get_tid(smc)
-struct s_smc *smc ;
+u_long smt_get_tid(struct s_smc *smc)
 {
 	u_long	tid ;
 	while ((tid = ++(smc->sm.smt_tid) ^ SMT_TID_MAGIC) == 0)
@@ -1723,10 +1643,8 @@
 
 #define N_SMT_PLEN	(sizeof(smt_pdef)/sizeof(smt_pdef[0]))
 
-int smt_check_para(smc,sm,list)
-struct s_smc *smc ;
-struct smt_header	*sm ;
-const u_short		list[] ;
+int smt_check_para(struct s_smc *smc, struct smt_header	*sm,
+		   const u_short list[])
 {
 	const u_short		*p = list ;
 	while (*p) {
@@ -1739,10 +1657,7 @@
 	return(0) ;
 }
 
-EXPORT_PMF void *sm_to_para(smc,sm,para)
-struct s_smc *smc ;
-struct smt_header	*sm ;
-int para ;
+void *sm_to_para(struct s_smc *smc, struct smt_header *sm, int para)
 {
 	char	*p ;
 	int	len ;
@@ -1773,9 +1688,7 @@
 	return(0) ;
 }
 
-int is_my_addr(smc,addr)
-struct s_smc *smc ;
-struct fddi_addr *addr ;
+int is_my_addr(struct s_smc *smc, struct fddi_addr *addr)
 {
 	return(*(short *)(&addr->a[0]) ==
 		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[0])
@@ -1785,31 +1698,26 @@
 		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[4])) ;
 }
 
-int is_zero(addr)
-struct fddi_addr *addr ;
+int is_zero(struct fddi_addr *addr)
 {
 	return(*(short *)(&addr->a[0]) == 0 &&
 	       *(short *)(&addr->a[2]) == 0 &&
 	       *(short *)(&addr->a[4]) == 0 ) ;
 }
 
-int is_broadcast(addr)
-struct fddi_addr *addr ;
+int is_broadcast(struct fddi_addr *addr)
 {
 	return(*(u_short *)(&addr->a[0]) == 0xffff &&
 	       *(u_short *)(&addr->a[2]) == 0xffff &&
 	       *(u_short *)(&addr->a[4]) == 0xffff ) ;
 }
 
-int is_individual(addr)
-struct fddi_addr *addr ;
+int is_individual(struct fddi_addr *addr)
 {
 	return(!(addr->a[0] & GROUP_ADDR)) ;
 }
 
-int is_equal(addr1,addr2)
-struct fddi_addr *addr1 ;
-struct fddi_addr *addr2 ;
+int is_equal(struct fddi_addr *addr1, struct fddi_addr *addr2)
 {
 	return(*(u_short *)(&addr1->a[0]) == *(u_short *)(&addr2->a[0]) &&
 	       *(u_short *)(&addr1->a[2]) == *(u_short *)(&addr2->a[2]) &&
@@ -1821,9 +1729,7 @@
 /*
  * send ANTC data test frame
  */
-void fddi_send_antc(smc,dest)
-struct s_smc *smc ;
-struct fddi_addr *dest ;
+void fddi_send_antc(struct s_smc *smc, struct fddi_addr *dest)
 {
 	SK_UNUSED(smc) ;
 	SK_UNUSED(dest) ;
@@ -1850,8 +1756,7 @@
 #ifdef	DEBUG
 #define hextoasc(x)	"0123456789abcdef"[x]
 
-char *addr_to_string(addr)
-struct fddi_addr *addr ;
+char *addr_to_string(struct fddi_addr *addr)
 {
 	int	i ;
 	static char	string[6*3] = "****" ;
@@ -1867,9 +1772,7 @@
 #endif
 
 #ifdef	AM29K
-smt_ifconfig(argc,argv)
-int argc ;
-char *argv[] ;
+smt_ifconfig(int argc, char *argv[])
 {
 	if (argc >= 2 && !strcmp(argv[0],"opt_bypass") &&
 	    !strcmp(argv[1],"yes")) {
@@ -1883,9 +1786,7 @@
 /*
  * return static mac index
  */
-static int mac_index(smc,mac)
-struct s_smc *smc ;
-int mac ;
+static int mac_index(struct s_smc *smc, int mac)
 {
 	SK_UNUSED(mac) ;
 #ifdef	CONCENTRATOR
@@ -1899,9 +1800,7 @@
 /*
  * return static phy index
  */
-static int phy_index(smc,phy)
-struct s_smc *smc ;
-int phy ;
+static int phy_index(struct s_smc *smc, int phy)
 {
 	SK_UNUSED(smc) ;
 	return(phy+1);
@@ -1910,9 +1809,7 @@
 /*
  * return dynamic mac connection resource index
  */
-static int mac_con_resource_index(smc,mac)
-struct s_smc *smc ;
-int mac ;
+static int mac_con_resource_index(struct s_smc *smc, int mac)
 {
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
@@ -1936,9 +1833,7 @@
 /*
  * return dynamic phy connection resource index
  */
-static int phy_con_resource_index(smc,phy)
-struct s_smc *smc ;
-int phy ;
+static int phy_con_resource_index(struct s_smc *smc, int phy)
 {
 #ifdef	CONCENTRATOR
 	return(entity_to_index(smc,cem_get_downstream(smc,ENTITY_PHY(phy)))) ;
@@ -1960,9 +1855,7 @@
 }
 
 #ifdef	CONCENTRATOR
-static int entity_to_index(smc,e)
-struct s_smc *smc ;
-int e ;
+static int entity_to_index(struct s_smc *smc, int e)
 {
 	if (e == ENTITY_MAC)
 		return(mac_index(smc,1)) ;
@@ -1972,16 +1865,13 @@
 #endif
 
 #ifdef	LITTLE_ENDIAN
-static int smt_swap_short(s)
-u_short s ;
+static int smt_swap_short(u_short s)
 {
 	return(((s>>8)&0xff)|((s&0xff)<<8)) ;
 }
 
-void smt_swap_para(sm,len,direction)
-struct smt_header *sm ;
-int len ;
-int direction ;			/* 0 encode 1 decode */
+void smt_swap_para(struct smt_header *sm, int len, int direction)
+/* int direction;	0 encode 1 decode */
 {
 	struct smt_para	*pa ;
 	const  struct smt_pdef	*pd ;
@@ -2027,10 +1917,7 @@
 	}
 }
 
-static void smt_string_swap(data,format,len)
-char *data ;
-const char *format ;
-int len ;
+static void smt_string_swap(char *data, const char *format, int len)
 {
 	const char	*open_paren = 0 ;
 	int	x ;
@@ -2081,10 +1968,8 @@
 	}
 }
 #else
-void smt_swap_para(sm,len,direction)
-struct smt_header *sm ;
-int len ;
-int direction ;			/* 0 encode 1 decode */
+void smt_swap_para(struct smt_header *sm, int len, int direction)
+/* int direction;	0 encode 1 decode */
 {
 	SK_UNUSED(sm) ;
 	SK_UNUSED(len) ;
@@ -2095,11 +1980,7 @@
 /*
  * PMF actions
  */
-int smt_action(smc,class,code,index)
-struct s_smc *smc ;
-int class ;
-int code ;
-int index ;
+int smt_action(struct s_smc *smc, int class, int code, int index)
 {
 	int	event ;
 	int	port ;
@@ -2190,9 +2071,7 @@
  *		set reconnect
  *	end
  */
-void smt_change_t_neg(smc,tneg)
-struct s_smc *smc ;
-u_long tneg ;
+void smt_change_t_neg(struct s_smc *smc, u_long tneg)
 {
 	smc->mib.a[PATH0].fddiPATHMaxT_Req = tneg ;
 
@@ -2207,10 +2086,7 @@
  * canonical conversion of <len> bytes beginning form *data
  */
 #ifdef  USE_CAN_ADDR
-void hwm_conv_can(smc,data,len)
-struct s_smc *smc ;
-char *data ;
-int len ;
+void hwm_conv_can(struct s_smc *smc, char *data, int len)
 {
 	int i ;
 
@@ -2223,3 +2099,4 @@
 #endif
 
 #endif	/* no SLIM_SMT */
+
diff -Nru a/drivers/net/skfp/smtdef.c b/drivers/net/skfp/smtdef.c
--- a/drivers/net/skfp/smtdef.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/smtdef.c	2004-06-17 14:49:49 -07:00
@@ -72,13 +72,11 @@
 #define DEFAULT_LCT_EXTEND	50
 
 /* Forward declarations */
-extern  void	smt_reset_defaults ();
-static	void	smt_init_mib ();
+void smt_reset_defaults(struct s_smc *smc, int level);
+static void smt_init_mib(struct s_smc *smc, int level);
+static int set_min_max(int maxflag, u_long mib, u_long limit, u_long *oper);
 
-static int set_min_max() ;
-
-void smt_set_defaults(smc)
-struct s_smc *smc ;
+void smt_set_defaults(struct s_smc *smc)
 {
 	smt_reset_defaults(smc,0) ;
 }
@@ -86,9 +84,7 @@
 #define MS2BCLK(x)	((x)*12500L)
 #define US2BCLK(x)	((x)*1250L)
 
-void smt_reset_defaults(smc,level)
-struct s_smc *smc ;
-int level ;
+void smt_reset_defaults(struct s_smc *smc, int level)
 {
 	struct smt_config	*smt ;
 	int			i ;
@@ -170,9 +166,7 @@
 /*	 01234567890123456789012345678901	*/
 	"xxxSK-NET FDDI SMT 7.3 - V2.8.8" ;
 
-static void smt_init_mib(smc,level)
-struct s_smc *smc ;
-int level ;
+static void smt_init_mib(struct s_smc *smc, int level)
 {
 	struct fddi_mib		*mib ;
 	struct fddi_mib_p	*pm ;
@@ -292,8 +286,7 @@
 	(void) smt_set_mac_opvalues(smc) ;
 }
 
-int smt_set_mac_opvalues(smc)
-struct s_smc *smc ;
+int smt_set_mac_opvalues(struct s_smc *smc)
 {
 	int	st ;
 	int	st2 ;
@@ -318,8 +311,7 @@
 	return(st) ;
 }
 
-void smt_fixup_mib(smc)
-struct s_smc *smc ;
+void smt_fixup_mib(struct s_smc *smc)
 {
 #ifdef	CONCENTRATOR
 	switch (smc->s.sas) {
@@ -355,11 +347,7 @@
  *	use mib
  * NOTE : numbers are negative, negate comparison !
  */
-static int set_min_max(maxflag,mib,limit,oper)
-int maxflag ;
-u_long mib ;
-u_long limit ;
-u_long *oper ;
+static int set_min_max(int maxflag, u_long mib, u_long limit, u_long *oper)
 {
 	u_long	old ;
 	old = *oper ;
@@ -369,3 +357,4 @@
 		*oper = mib ;
 	return(old != *oper) ;
 }
+
diff -Nru a/drivers/net/skfp/smtinit.c b/drivers/net/skfp/smtinit.c
--- a/drivers/net/skfp/smtinit.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/smtinit.c	2004-06-17 14:49:49 -07:00
@@ -27,7 +27,7 @@
 static const char ID_sccs[] = "@(#)smtinit.c	1.15 97/05/06 (C) SK " ;
 #endif
 
-extern void init_fddi_driver() ;
+void init_fddi_driver(struct s_smc *smc, u_char *mac_addr);
 
 /* define global debug variable */
 #if defined(DEBUG) && !defined(DEBUG_BRD)
@@ -48,8 +48,7 @@
  * Can not be called in smt_reset_defaults, because it is not sure that
  * the OEM ID is already defined.
  */
-static void set_oem_spec_val(smc)
-struct s_smc *smc ;
+static void set_oem_spec_val(struct s_smc *smc)
 {
 	struct fddi_mib *mib ;
 
@@ -66,9 +65,8 @@
 /*
  * Init SMT
  */
-int init_smt(smc,mac_addr)
-struct s_smc *smc ;
-u_char *mac_addr ;		/* canonical address or NULL */
+int init_smt(struct s_smc *smc, u_char *mac_addr)
+/* u_char *mac_addr;	canonical address or NULL */
 {
 	int	p ;
 
@@ -124,3 +122,4 @@
 
 	return(0) ;
 }
+
diff -Nru a/drivers/net/skfp/smtparse.c b/drivers/net/skfp/smtparse.c
--- a/drivers/net/skfp/smtparse.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/smtparse.c	2004-06-17 14:49:49 -07:00
@@ -82,8 +82,9 @@
 /*
  * local function declarations
  */
-static u_long parse_num() ;
-static int parse_word() ;
+static u_long parse_num(int type, char _far *value, char *v, u_long mn,
+			u_long mx, int scale);
+static int parse_word(char *buf, char _far *text);
 
 #ifdef SIM
 #define DB_MAIN(a,b,c)	printf(a,b,c)
@@ -117,11 +118,8 @@
  *
  * END_MANUAL_ENTRY()
  */
-int smt_parse_arg(smc,keyword,type,value)
-struct s_smc *smc ;
-char _far *keyword ;
-int type ;
-char _far *value ;
+int smt_parse_arg(struct s_smc *smc, char _far *keyword, int type,
+		  char _far *value)
 {
 	char		keybuf[MAX_VAL+1];
 	char		valbuf[MAX_VAL+1];
@@ -287,9 +285,7 @@
 	return(0) ;
 }
 
-static int parse_word(buf,text)
-char *buf ;
-char _far *text ;
+static int parse_word(char *buf, char _far *text)
 {
 	char		c ;
 	char 		*p ;
@@ -364,13 +360,8 @@
 	return(0) ;
 }
 
-static u_long parse_num(type,value,v,mn,mx,scale)
-int type ;
-char _far *value ;
-char *v ;
-u_long mn ;
-u_long mx ;
-int scale ;
+static u_long parse_num(int type, char _far *value, char *v, u_long mn,
+			u_long mx, int scale)
 {
 	u_long	x = 0 ;
 	char	c ;
@@ -473,3 +464,4 @@
 	exit(0) ;
 }
 #endif
+
diff -Nru a/drivers/net/skfp/smttimer.c b/drivers/net/skfp/smttimer.c
--- a/drivers/net/skfp/smttimer.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/smttimer.c	2004-06-17 14:49:49 -07:00
@@ -26,18 +26,9 @@
 static const char ID_sccs[] = "@(#)smttimer.c	2.4 97/08/04 (C) SK " ;
 #endif
 
-/*
- * external function declarations
- */
-extern u_long hwt_read() ;
-extern void hwt_stop() ;
-extern void hwt_start() ;
+static void timer_done(struct s_smc *smc, int restart);
 
-static void timer_done() ;
-
-
-void smt_timer_init(smc)
-struct s_smc *smc ;
+void smt_timer_init(struct s_smc *smc)
 {
 	smc->t.st_queue = 0 ;
 	smc->t.st_fast.tm_active = FALSE ;
@@ -45,9 +36,7 @@
 	hwt_init(smc) ;
 }
 
-void smt_timer_stop(smc,timer)
-struct s_smc *smc ;
-struct smt_timer *timer ;
+void smt_timer_stop(struct s_smc *smc, struct smt_timer *timer)
 {
 	struct smt_timer	**prev ;
 	struct smt_timer	*tm ;
@@ -70,11 +59,8 @@
 	}
 }
 
-void smt_timer_start(smc,timer,time,token)
-struct s_smc *smc ;
-struct smt_timer *timer ;
-u_long		time ;
-u_long		token ;
+void smt_timer_start(struct s_smc *smc, struct smt_timer *timer, u_long time,
+		     u_long token)
 {
 	struct smt_timer	**prev ;
 	struct smt_timer	*tm ;
@@ -121,21 +107,17 @@
 	hwt_start(smc,smc->t.st_queue->tm_delta) ;
 }
 
-void smt_force_irq(smc)
-struct s_smc *smc ;
+void smt_force_irq(struct s_smc *smc)
 {
 	smt_timer_start(smc,&smc->t.st_fast,32L, EV_TOKEN(EVENT_SMT,SM_FAST)); 
 }
 
-void smt_timer_done(smc)
-struct s_smc *smc ;
+void smt_timer_done(struct s_smc *smc)
 {
 	timer_done(smc,1) ;
 }
 
-static void timer_done(smc,restart)
-struct s_smc *smc ;
-int restart ;
+static void timer_done(struct s_smc *smc, int restart)
 {
 	u_long			delta ;
 	struct smt_timer	*tm ;
@@ -171,3 +153,4 @@
 	if (restart && smc->t.st_queue)
 		hwt_start(smc,smc->t.st_queue->tm_delta) ;
 }
+
diff -Nru a/drivers/net/skfp/srf.c b/drivers/net/skfp/srf.c
--- a/drivers/net/skfp/srf.c	2004-06-17 14:49:49 -07:00
+++ b/drivers/net/skfp/srf.c	2004-06-17 14:49:49 -07:00
@@ -38,10 +38,10 @@
 /*
  * function declarations
  */
-static void clear_all_rep() ;
-static void clear_reported() ;
-static void smt_send_srf() ;
-static struct s_srf_evc *smt_get_evc() ;
+static void clear_all_rep(struct s_smc *smc);
+static void clear_reported(struct s_smc *smc);
+static void smt_send_srf(struct s_smc *smc);
+static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index);
 
 #define MAX_EVCS	(sizeof(smc->evcs)/sizeof(smc->evcs[0]))
 
@@ -69,8 +69,7 @@
 
 #define MAX_INIT_EVC	(sizeof(evc_inits)/sizeof(evc_inits[0]))
 
-void smt_init_evc(smc)
-struct s_smc *smc ;
+void smt_init_evc(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
 	const struct evc_init 	*init ;
@@ -159,10 +158,7 @@
 	smc->srf.sr_state = SR0_WAIT ;
 }
 
-static struct s_srf_evc *smt_get_evc(smc,code,index)
-struct s_smc *smc ;
-int code ;
-int index ;
+static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index)
 {
 	int			i ;
 	struct s_srf_evc	*evc ;
@@ -188,11 +184,7 @@
 } ;
 #endif
 
-void smt_srf_event(smc,code,index,cond)
-struct s_smc *smc ;
-int code ;
-int index ;
-int cond ;
+void smt_srf_event(struct s_smc *smc, int code, int index, int cond)
 {
 	struct s_srf_evc	*evc ;
 	int			cond_asserted = 0 ;
@@ -340,8 +332,7 @@
 	}
 }
 
-static void clear_all_rep(smc)
-struct s_smc *smc ;
+static void clear_all_rep(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
 	int			i ;
@@ -354,8 +345,7 @@
 	smc->srf.any_report = FALSE ;
 }
 
-static void clear_reported(smc)
-struct s_smc *smc ;
+static void clear_reported(struct s_smc *smc)
 {
 	struct s_srf_evc	*evc ;
 	int			i ;
@@ -375,13 +365,10 @@
 	}
 }
 
-extern SMbuf *smt_build_frame() ;
-
 /*
  * build and send SMT SRF frame
  */
-static void smt_send_srf(smc)
-struct s_smc *smc ;
+static void smt_send_srf(struct s_smc *smc)
 {
 
 	struct smt_header	*smt ;
@@ -439,3 +426,4 @@
 
 #endif	/* no BOOT */
 #endif	/* no SLIM_SMT */
+
