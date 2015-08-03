From: Joe Perches <joe@perches.com>
Subject: [PATCH] fddi: Use a more more typical logging style
Date: Sun, 02 Aug 2015 21:27:45 -0700
Message-ID: <1438576065.30149.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0128.hostedemail.com ([216.40.44.128]:33248 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750956AbbHCE21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 00:28:27 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay05.hostedemail.com (Postfix) with ESMTP id C627C268E25
	for <netdev@vger.kernel.org>; Mon,  3 Aug 2015 04:28:25 +0000 (UTC)
Received: from joe-X200MA.home (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf08.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  3 Aug 2015 04:28:23 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use macros that don't require fixed argument counts so
format and arguments can be verified by the compiler.

Miscellanea:

o Remove a few #if uses to allow dynamic debug to always work
o whitespace neatening

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/fddi/skfp/cfm.c        | 16 +++----
 drivers/net/fddi/skfp/drvfbi.c     |  2 +-
 drivers/net/fddi/skfp/ecm.c        | 16 +++----
 drivers/net/fddi/skfp/ess.c        | 51 ++++++++++----------
 drivers/net/fddi/skfp/fplustm.c    | 10 ++--
 drivers/net/fddi/skfp/h/cmtdef.h   | 95 +++++++++++++++++++++++++-------------
 drivers/net/fddi/skfp/h/osdef1st.h |  2 +
 drivers/net/fddi/skfp/pcmplc.c     | 29 ++++++------
 drivers/net/fddi/skfp/pmf.c        |  2 +-
 drivers/net/fddi/skfp/rmt.c        | 28 ++++++-----
 drivers/net/fddi/skfp/smt.c        | 72 ++++++++++++++---------------
 drivers/net/fddi/skfp/srf.c        | 12 ++---
 12 files changed, 179 insertions(+), 156 deletions(-)

diff --git a/drivers/net/fddi/skfp/cfm.c b/drivers/net/fddi/skfp/cfm.c
index e395ace..e2fab03 100644
--- a/drivers/net/fddi/skfp/cfm.c
+++ b/drivers/net/fddi/skfp/cfm.c
@@ -52,7 +52,6 @@ static const char ID_sccs[] = "@(#)cfm.c      2.18 98/10/06 (C) SK " ;
 #define ACTIONS_DONE() (smc->mib.fddiSMTCF_State &= ~AFLAG)
 #define ACTIONS(x)     (x|AFLAG)
 
-#ifdef DEBUG
 /*
  * symbolic state names
  */
@@ -68,7 +67,6 @@ static const char * const cfm_states[] = {
 static const char * const cfm_events[] = {
        "NONE","CF_LOOP_A","CF_LOOP_B","CF_JOIN_A","CF_JOIN_B"
 } ;
-#endif
 
 /*
  * map from state to downstream port type
@@ -233,7 +231,7 @@ void cfm(struct s_smc *smc, int event)
                DB_CFM("CFM : state %s%s",
                        (smc->mib.fddiSMTCF_State & AFLAG) ? "ACTIONS " : "",
                        cfm_states[smc->mib.fddiSMTCF_State & ~AFLAG]) ;
-               DB_CFM(" event %s\n",cfm_events[event],0) ;
+               DB_CFM(" event %s\n", cfm_events[event]);
                state = smc->mib.fddiSMTCF_State ;
                cfm_fsm(smc,event) ;
                event = 0 ;
@@ -297,7 +295,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                /* Don't do the WC-Flag changing here */
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break;
        case SC0_ISOLATED :
                /*SC07*/
@@ -338,7 +336,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                        queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                }
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break ;
        case SC9_C_WRAP_A :
                /*SC10*/
@@ -403,7 +401,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                        queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                }
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break ;
        case SC10_C_WRAP_B :
                /*SC20*/
@@ -448,7 +446,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                smc->r.rm_join = TRUE ;
                queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break ;
        case SC4_THRU_A :
                /*SC41*/
@@ -481,7 +479,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                smc->r.rm_join = TRUE ;
                queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break ;
        case SC5_THRU_B :
                /*SC51*/
@@ -519,7 +517,7 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
                        queue_event(smc,EVENT_RMT,RM_JOIN) ;/* signal RMT */
                }
                ACTIONS_DONE() ;
-               DB_CFMN(1,"CFM : %s\n",cfm_states[smc->mib.fddiSMTCF_State],0) ;
+               DB_CFMN(1, "CFM : %s\n", cfm_states[smc->mib.fddiSMTCF_State]);
                break ;
        case SC11_C_WRAP_S :
                /*SC70*/
diff --git a/drivers/net/fddi/skfp/drvfbi.c b/drivers/net/fddi/skfp/drvfbi.c
index 07da97c..6f85461 100644
--- a/drivers/net/fddi/skfp/drvfbi.c
+++ b/drivers/net/fddi/skfp/drvfbi.c
@@ -344,7 +344,7 @@ void init_board(struct s_smc *smc, u_char *mac_addr)
 void sm_pm_bypass_req(struct s_smc *smc, int mode)
 {
        DB_ECMN(1,"ECM : sm_pm_bypass_req(%s)\n",(mode == BP_INSERT) ?
-                                       "BP_INSERT" : "BP_DEINSERT",0) ;
+                                       "BP_INSERT" : "BP_DEINSERT");
 
        if (smc->s.sas != SMT_DAS)
                return ;
diff --git a/drivers/net/fddi/skfp/ecm.c b/drivers/net/fddi/skfp/ecm.c
index 47d922c..2a8decb 100644
--- a/drivers/net/fddi/skfp/ecm.c
+++ b/drivers/net/fddi/skfp/ecm.c
@@ -66,7 +66,6 @@ static const char ID_sccs[] = "@(#)ecm.c      2.7 99/08/05 (C) SK " ;
 #define EC6_CHECK      6                       /* checking bypass */
 #define EC7_DEINSERT   7                       /* bypass being turnde off */
 
-#ifdef DEBUG
 /*
  * symbolic state names
  */
@@ -83,7 +82,6 @@ static const char * const ecm_events[] = {
        "EC_TIMEOUT_TD","EC_TIMEOUT_TMAX",
        "EC_TIMEOUT_IMAX","EC_TIMEOUT_INMAX","EC_TEST_DONE"
 } ;
-#endif
 
 /*
  * all Globals  are defined in smc.h
@@ -129,7 +127,7 @@ void ecm(struct s_smc *smc, int event)
                DB_ECM("ECM : state %s%s",
                        (smc->mib.fddiSMTECMState & AFLAG) ? "ACTIONS " : "",
                        ecm_states[smc->mib.fddiSMTECMState & ~AFLAG]) ;
-               DB_ECM(" event %s\n",ecm_events[event],0) ;
+               DB_ECM(" event %s\n", ecm_events[event]);
                state = smc->mib.fddiSMTECMState ;
                ecm_fsm(smc,event) ;
                event = 0 ;
@@ -379,7 +377,7 @@ static void ecm_fsm(struct s_smc *smc, int cmd)
                         (((ls_a == PC_ILS) && (ls_b == PC_QLS)) ||
                          ((ls_a == PC_QLS) && (ls_b == PC_ILS)))){
                        smc->e.sb_flag = TRUE ;
-                       DB_ECMN(1,"ECM : EC6_CHECK - stuck bypass\n",0,0) ;
+                       DB_ECMN(1, "ECM : EC6_CHECK - stuck bypass\n");
                        AIX_EVENT(smc, (u_long) FDDI_RING_STATUS, (u_long)
                                FDDI_SMT_ERROR, (u_long) FDDI_BYPASS_STUCK,
                                smt_get_error_word(smc));
@@ -443,29 +441,29 @@ static void prop_actions(struct s_smc *smc)
                return ;
        }
 
-       DB_ECM("ECM : prop_actions - trace_prop %d\n", smc->e.trace_prop,0) ;
+       DB_ECM("ECM : prop_actions - trace_prop %lu\n", smc->e.trace_prop);
        DB_ECM("ECM : prop_actions - in %d out %d\n", port_in,port_out) ;
 
        if (smc->e.trace_prop & ENTITY_BIT(ENTITY_MAC)) {
                /* trace initiatior */
-               DB_ECM("ECM : initiate TRACE on PHY %c\n",'A'+port_in-PA,0) ;
+               DB_ECM("ECM : initiate TRACE on PHY %c\n", 'A' + port_in - PA);
                queue_event(smc,EVENT_PCM+port_in,PC_TRACE) ;
        }
        else if ((smc->e.trace_prop & ENTITY_BIT(ENTITY_PHY(PA))) &&
                port_out != PA) {
                /* trace propagate upstream */
-               DB_ECM("ECM : propagate TRACE on PHY B\n",0,0) ;
+               DB_ECM("ECM : propagate TRACE on PHY B\n");
                queue_event(smc,EVENT_PCMB,PC_TRACE) ;
        }
        else if ((smc->e.trace_prop & ENTITY_BIT(ENTITY_PHY(PB))) &&
                port_out != PB) {
                /* trace propagate upstream */
-               DB_ECM("ECM : propagate TRACE on PHY A\n",0,0) ;
+               DB_ECM("ECM : propagate TRACE on PHY A\n");
                queue_event(smc,EVENT_PCMA,PC_TRACE) ;
        }
        else {
                /* signal trace termination */
-               DB_ECM("ECM : TRACE terminated\n",0,0) ;
+               DB_ECM("ECM : TRACE terminated\n");
                smc->e.path_test = PT_PENDING ;
        }
        smc->e.trace_prop = 0 ;
diff --git a/drivers/net/fddi/skfp/ess.c b/drivers/net/fddi/skfp/ess.c
index 2fc5987..fb88d41 100644
--- a/drivers/net/fddi/skfp/ess.c
+++ b/drivers/net/fddi/skfp/ess.c
@@ -134,7 +134,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
         * get the resource type
         */
        if (!(p = (void *) sm_to_para(smc,sm,SMT_P0015))) {
-               DB_ESS("ESS: RAF frame error, parameter type not found\n",0,0) ;
+               DB_ESS("ESS: RAF frame error, parameter type not found\n");
                return fs;
        }
        msg_res_type = ((struct smt_p_0015 *)p)->res_type ;
@@ -146,16 +146,16 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                /*
                 * error in frame: para ESS command was not found
                 */
-                DB_ESS("ESS: RAF frame error, parameter command not found\n",0,0);
+                DB_ESS("ESS: RAF frame error, parameter command not found\n");
                 return fs;
        }
 
        DB_ESSN(2,"fc %x        ft %x\n",sm->smt_class,sm->smt_type) ;
-       DB_ESSN(2,"ver %x       tran %lx\n",sm->smt_version,sm->smt_tid) ;
-       DB_ESSN(2,"stn_id %s\n",addr_to_string(&sm->smt_source),0) ;
+       DB_ESSN(2, "ver %x      tran %x\n", sm->smt_version, sm->smt_tid);
+       DB_ESSN(2, "stn_id %s\n", addr_to_string(&sm->smt_source));
 
-       DB_ESSN(2,"infolen %x   res %x\n",sm->smt_len, msg_res_type) ;
-       DB_ESSN(2,"sbacmd %x\n",cmd->sba_cmd,0) ;
+       DB_ESSN(2, "infolen %x  res %lu\n", sm->smt_len, msg_res_type);
+       DB_ESSN(2, "sbacmd %x\n", cmd->sba_cmd);
 
        /*
         * evaluate the ESS command
@@ -189,7 +189,8 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                         *       The ESS do not send the Frame to the network!
                         */
                        smc->ess.alloc_trans_id = sm->smt_tid ;
-                       DB_ESS("ESS: save Alloc Req Trans ID %lx\n",sm->smt_tid,0);
+                       DB_ESS("ESS: save Alloc Req Trans ID %x\n",
+                              sm->smt_tid);
                        p = (void *) sm_to_para(smc,sm,SMT_P320F) ;
                        ((struct smt_p_320f *)p)->mib_payload =
                                smc->mib.a[PATH0].fddiPATHSbaPayload ;
@@ -220,7 +221,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                 * check the parameters
                 */
                if (smt_check_para(smc,sm,plist_raf_alc_res)) {
-                       DB_ESS("ESS: RAF with para problem, ignoring\n",0,0) ;
+                       DB_ESS("ESS: RAF with para problem, ignoring\n");
                        return fs;
                }
 
@@ -241,7 +242,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                        != SMT_RDF_SUCCESS) ||
                        (sm->smt_tid != smc->ess.alloc_trans_id)) {
 
-                       DB_ESS("ESS: Allocation Response not accepted\n",0,0) ;
+                       DB_ESS("ESS: Allocation Response not accepted\n");
                        return fs;
                }
 
@@ -279,7 +280,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                 * except only replies
                 */
                if (sm->smt_type != SMT_REQUEST) {
-                       DB_ESS("ESS: Do not process Change Responses\n",0,0) ;
+                       DB_ESS("ESS: Do not process Change Responses\n");
                        return fs;
                }
 
@@ -287,7 +288,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                 * check the para for the Change Request
                 */
                if (smt_check_para(smc,sm,plist_raf_chg_req)) {
-                       DB_ESS("ESS: RAF with para problem, ignoring\n",0,0) ;
+                       DB_ESS("ESS: RAF with para problem, ignoring\n");
                        return fs;
                }
 
@@ -299,7 +300,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                 */
                if ((((struct smt_p_320b *)sm_to_para(smc,sm,SMT_P320B))->path_index
                        != PRIMARY_RING) || (msg_res_type != SYNC_BW)) {
-                       DB_ESS("ESS: RAF frame with para problem, ignoring\n",0,0) ;
+                       DB_ESS("ESS: RAF frame with para problem, ignoring\n");
                        return fs;
                }
 
@@ -312,7 +313,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                overhead = ((struct smt_p_3210 *)p)->mib_overhead ;
 
                DB_ESSN(2,"ESS: Change Request from %s\n",
-                       addr_to_string(&sm->smt_source),0) ;
+                       addr_to_string(&sm->smt_source));
                DB_ESSN(2,"payload= %lx overhead= %lx\n",payload,overhead) ;
 
                /*
@@ -337,18 +338,18 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                 * except only requests
                 */
                if (sm->smt_type != SMT_REQUEST) {
-                       DB_ESS("ESS: Do not process a Report Reply\n",0,0) ;
+                       DB_ESS("ESS: Do not process a Report Reply\n");
                        return fs;
                }
 
                DB_ESSN(2,"ESS: Report Request from %s\n",
-                       addr_to_string(&(sm->smt_source)),0) ;
+                       addr_to_string(&sm->smt_source));
 
                /*
                 * verify that the resource type is sync bw only
                 */
                if (msg_res_type != SYNC_BW) {
-                       DB_ESS("ESS: ignoring RAF with para problem\n",0,0) ;
+                       DB_ESS("ESS: ignoring RAF with para problem\n");
                        return fs;
                }
 
@@ -364,7 +365,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
                /*
                 * error in frame
                 */
-               DB_ESS("ESS: ignoring RAF with bad sba_cmd\n",0,0) ;
+               DB_ESS("ESS: ignoring RAF with bad sba_cmd\n");
                break ;
        }
 
@@ -427,7 +428,7 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
 
        /* premliminary */
        if (payload > MAX_PAYLOAD || overhead > 5000) {
-               DB_ESS("ESS: payload / overhead not accepted\n",0,0) ;
+               DB_ESS("ESS: payload / overhead not accepted\n");
                return FALSE;
        }
 
@@ -446,7 +447,7 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
         * evulate the Payload
         */
        if (payload) {
-               DB_ESSN(2,"ESS: turn SMT_ST_SYNC_SERVICE bit on\n",0,0) ;
+               DB_ESSN(2, "ESS: turn SMT_ST_SYNC_SERVICE bit on\n");
                smc->ess.sync_bw_available = TRUE ;
 
                smc->ess.sync_bw = overhead -
@@ -454,7 +455,7 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
                        payload / 1562 ;
        }
        else {
-               DB_ESSN(2,"ESS: turn SMT_ST_SYNC_SERVICE bit off\n",0,0) ;
+               DB_ESSN(2, "ESS: turn SMT_ST_SYNC_SERVICE bit off\n");
                smc->ess.sync_bw_available = FALSE ;
                smc->ess.sync_bw = 0 ;
                overhead = 0 ;
@@ -464,7 +465,7 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
        smc->mib.a[PATH0].fddiPATHSbaOverhead = overhead ;
 
 
-       DB_ESSN(2,"tsync = %lx\n",smc->ess.sync_bw,0) ;
+       DB_ESSN(2, "tsync = %lx\n", smc->ess.sync_bw);
 
        ess_config_fifo(smc) ;
        set_formac_tsync(smc,smc->ess.sync_bw) ;
@@ -541,7 +542,7 @@ void ess_timer_poll(struct s_smc *smc)
        if (!smc->ess.raf_act_timer_poll)
                return ;
 
-       DB_ESSN(2,"ESS: timer_poll\n",0,0) ;
+       DB_ESSN(2, "ESS: timer_poll\n");
 
        smc->ess.timer_count++ ;
        if (smc->ess.timer_count == 10) {
@@ -667,11 +668,11 @@ static void ess_send_frame(struct s_smc *smc, SMbuf *mb)
                /*
                 * Send the Change Reply to the local SBA
                 */
-               DB_ESS("ESS:Send to the local SBA\n",0,0) ;
+               DB_ESS("ESS:Send to the local SBA\n");
                if (!smc->ess.sba_reply_pend)
                        smc->ess.sba_reply_pend = mb ;
                else {
-                       DB_ESS("Frame is lost - another frame was pending\n",0,0);
+                       DB_ESS("Frame is lost - another frame was pending\n");
                        smt_free_mbuf(smc,mb) ;
                }
        }
@@ -679,7 +680,7 @@ static void ess_send_frame(struct s_smc *smc, SMbuf *mb)
                /*
                 * Send the SBA RAF Change Reply to the network
                 */
-               DB_ESS("ESS:Send to the network\n",0,0) ;
+               DB_ESS("ESS:Send to the network\n");
                smt_send_frame(smc,mb,FC_SMT_INFO,0) ;
        }
 }
diff --git a/drivers/net/fddi/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
index 7d3779a..403e149 100644
--- a/drivers/net/fddi/skfp/fplustm.c
+++ b/drivers/net/fddi/skfp/fplustm.c
@@ -726,7 +726,7 @@ void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l)
        if (code_s2u & FM_SMYBEC)
                queue_event(smc,EVENT_RMT,RM_MY_BEACON) ;
        if (change_s2u & code_s2u & FM_SLOCLM) {
-               DB_RMTN(2,"RMT : lower claim received\n",0,0) ;
+               DB_RMTN(2, "RMT : lower claim received\n");
        }
        if ((code_s2u & FM_SMYCLM) && !(code_s2l & FM_SDUPCLM)) {
                /*
@@ -746,7 +746,7 @@ void mac2_irq(struct s_smc *smc, u_short code_s2u, u_short code_s2l)
                queue_event(smc,EVENT_RMT,RM_VALID_CLAIM) ;
        }
        if (change_s2u & code_s2u & FM_SHICLM) {
-               DB_RMTN(2,"RMT : higher claim received\n",0,0) ;
+               DB_RMTN(2, "RMT : higher claim received\n");
        }
        if ( (code_s2l & FM_STRTEXP) ||
             (code_s2l & FM_STRTEXR) )
@@ -1334,7 +1334,7 @@ void rtm_irq(struct s_smc *smc)
        outpw(ADDR(B2_RTM_CRTL),TIM_CL_IRQ) ;           /* clear IRQ */
        if (inpw(ADDR(B2_RTM_CRTL)) & TIM_RES_TOK) {
                outpw(FM_A(FM_CMDREG1),FM_ICL) ;        /* force claim */
-               DB_RMT("RMT: fddiPATHT_Rmode expired\n",0,0) ;
+               DB_RMT("RMT: fddiPATHT_Rmode expired\n");
                AIX_EVENT(smc, (u_long) FDDI_RING_STATUS,
                                (u_long) FDDI_SMT_EVENT,
                                (u_long) FDDI_RTT, smt_get_event_word(smc));
@@ -1354,7 +1354,7 @@ void rtm_set_timer(struct s_smc *smc)
         * MIB timer and hardware timer have the same resolution of 80nS
         */
        DB_RMT("RMT: setting new fddiPATHT_Rmode, t = %d ns\n",
-               (int) smc->mib.a[PATH0].fddiPATHT_Rmode,0) ;
+               (int)smc->mib.a[PATH0].fddiPATHT_Rmode);
        outpd(ADDR(B2_RTM_INI),smc->mib.a[PATH0].fddiPATHT_Rmode) ;
 }
 
@@ -1469,7 +1469,7 @@ static void smt_split_up_fifo(struct s_smc *smc)
        smc->hw.fp.fifo.rx2_fifo_start = smc->hw.fp.fifo.tx_a0_start +
                smc->hw.fp.fifo.tx_a0_size ;
 
-       DB_SMT("FIFO split: mode = %x\n",smc->hw.fp.fifo.fifo_config_mode,0) ;
+       DB_SMT("FIFO split: mode = %x\n", smc->hw.fp.fifo.fifo_config_mode);
        DB_SMT("rbc_ram_start = %x       rbc_ram_end =  %x\n",
                smc->hw.fp.fifo.rbc_ram_start, smc->hw.fp.fifo.rbc_ram_end) ;
        DB_SMT("rx1_fifo_start = %x      tx_s_start =   %x\n",
diff --git a/drivers/net/fddi/skfp/h/cmtdef.h b/drivers/net/fddi/skfp/h/cmtdef.h
index f5bc90f..b0c0b96 100644
--- a/drivers/net/fddi/skfp/h/cmtdef.h
+++ b/drivers/net/fddi/skfp/h/cmtdef.h
@@ -54,41 +54,71 @@
 #endif
 
 #ifdef DEBUG
-#define        DB_PR(flag,a,b,c)       { if (flag) printf(a,b,c) ; }
+#define        DB_PR(flag, fmt, ...)                                           \
+       do { if (flag) printf(fmt, ##__VA_ARGS__); } while (0)
 #else
-#define        DB_PR(flag,a,b,c)
+#define        DB_PR(flag, fmt, ...)                                           \
+       do { if (0) printf(fmt, ##__VA_ARGS__); } while (0)
 #endif
 
 #ifdef DEBUG_BRD
-#define DB_ECM(a,b,c)          DB_PR((smc->debug.d_smt&1),a,b,c)
-#define DB_ECMN(n,a,b,c)       DB_PR((smc->debug.d_ecm >=(n)),a,b,c)
-#define DB_RMT(a,b,c)          DB_PR((smc->debug.d_smt&2),a,b,c)
-#define DB_RMTN(n,a,b,c)       DB_PR((smc->debug.d_rmt >=(n)),a,b,c)
-#define DB_CFM(a,b,c)          DB_PR((smc->debug.d_smt&4),a,b,c)
-#define DB_CFMN(n,a,b,c)       DB_PR((smc->debug.d_cfm >=(n)),a,b,c)
-#define DB_PCM(a,b,c)          DB_PR((smc->debug.d_smt&8),a,b,c)
-#define DB_PCMN(n,a,b,c)       DB_PR((smc->debug.d_pcm >=(n)),a,b,c)
-#define DB_SMT(a,b,c)          DB_PR((smc->debug.d_smtf),a,b,c)
-#define DB_SMTN(n,a,b,c)       DB_PR((smc->debug.d_smtf >=(n)),a,b,c)
-#define DB_SBA(a,b,c)          DB_PR((smc->debug.d_sba),a,b,c)
-#define DB_SBAN(n,a,b,c)       DB_PR((smc->debug.d_sba >=(n)),a,b,c)
-#define DB_ESS(a,b,c)          DB_PR((smc->debug.d_ess),a,b,c)
-#define DB_ESSN(n,a,b,c)       DB_PR((smc->debug.d_ess >=(n)),a,b,c)
+#define DB_ECM(fmt, ...)                                               \
+       DB_PR(smc->debug.d_smt & 1, fmt, ##__VA_ARGS__)
+#define DB_ECMN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_ecm >= (n), fmt, ##__VA_ARGS__)
+#define DB_RMT(fmt, ...)                                               \
+       DB_PR(smc->debug.d_smt & 2, fmt, ##__VA_ARGS__)
+#define DB_RMTN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_rmt >= (n), fmt, ##__VA_ARGS__)
+#define DB_CFM(fmt, ...)                                               \
+       DB_PR(smc->debug.d_smt & 4, fmt, ##__VA_ARGS__)
+#define DB_CFMN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_cfm >= (n), fmt, ##__VA_ARGS__)
+#define DB_PCM(fmt, ...)                                               \
+       DB_PR(smc->debug.d_smt & 8, fmt, ##__VA_ARGS__)
+#define DB_PCMN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_pcm >= (n), fmt, ##__VA_ARGS__)
+#define DB_SMT(fmt, ...)                                               \
+       DB_PR(smc->debug.d_smtf, fmt, ##__VA_ARGS__)
+#define DB_SMTN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_smtf >= (n), fmt, ##__VA_ARGS__)
+#define DB_SBA(fmt, ...)                                               \
+       DB_PR(smc->debug.d_sba, fmt, ##__VA_ARGS__)
+#define DB_SBAN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_sba >= (n), fmt, ##__VA_ARGS__)
+#define DB_ESS(fmt, ...)                                               \
+       DB_PR(smc->debug.d_ess, fmt, ##__VA_ARGS__)
+#define DB_ESSN(n, fmt, ...)                                           \
+       DB_PR(smc->debug.d_ess >= (n), fmt, ##__VA_ARGS__)
 #else
-#define DB_ECM(a,b,c)          DB_PR((debug.d_smt&1),a,b,c)
-#define DB_ECMN(n,a,b,c)       DB_PR((debug.d_ecm >=(n)),a,b,c)
-#define DB_RMT(a,b,c)          DB_PR((debug.d_smt&2),a,b,c)
-#define DB_RMTN(n,a,b,c)       DB_PR((debug.d_rmt >=(n)),a,b,c)
-#define DB_CFM(a,b,c)          DB_PR((debug.d_smt&4),a,b,c)
-#define DB_CFMN(n,a,b,c)       DB_PR((debug.d_cfm >=(n)),a,b,c)
-#define DB_PCM(a,b,c)          DB_PR((debug.d_smt&8),a,b,c)
-#define DB_PCMN(n,a,b,c)       DB_PR((debug.d_pcm >=(n)),a,b,c)
-#define DB_SMT(a,b,c)          DB_PR((debug.d_smtf),a,b,c)
-#define DB_SMTN(n,a,b,c)       DB_PR((debug.d_smtf >=(n)),a,b,c)
-#define DB_SBA(a,b,c)          DB_PR((debug.d_sba),a,b,c)
-#define DB_SBAN(n,a,b,c)       DB_PR((debug.d_sba >=(n)),a,b,c)
-#define DB_ESS(a,b,c)          DB_PR((debug.d_ess),a,b,c)
-#define DB_ESSN(n,a,b,c)       DB_PR((debug.d_ess >=(n)),a,b,c)
+#define DB_ECM(fmt, ...)                                               \
+       DB_PR(debug.d_smt & 1, fmt, ##__VA_ARGS__)
+#define DB_ECMN(n, fmt, ...)                                           \
+       DB_PR(debug.d_ecm >= (n), fmt, ##__VA_ARGS__)
+#define DB_RMT(fmt, ...)                                               \
+       DB_PR(debug.d_smt & 2, fmt, ##__VA_ARGS__)
+#define DB_RMTN(n, fmt, ...)                                           \
+       DB_PR(debug.d_rmt >= (n), fmt, ##__VA_ARGS__)
+#define DB_CFM(fmt, ...)                                               \
+       DB_PR(debug.d_smt & 4, fmt, ##__VA_ARGS__)
+#define DB_CFMN(n, fmt, ...)                                           \
+       DB_PR(debug.d_cfm >= (n), fmt, ##__VA_ARGS__)
+#define DB_PCM(fmt, ...)                                               \
+       DB_PR(debug.d_smt & 8, fmt, ##__VA_ARGS__)
+#define DB_PCMN(n, fmt, ...)                                           \
+       DB_PR(debug.d_pcm >= (n), fmt, ##__VA_ARGS__)
+#define DB_SMT(fmt, ...)                                               \
+       DB_PR(debug.d_smtf, fmt, ##__VA_ARGS__)
+#define DB_SMTN(n, fmt, ...)                                           \
+       DB_PR(debug.d_smtf >= (n), fmt, ##__VA_ARGS__)
+#define DB_SBA(fmt, ...)                                               \
+       DB_PR(debug.d_sba, fmt, ##__VA_ARGS__)
+#define DB_SBAN(n, fmt, ...)                                           \
+       DB_PR(debug.d_sba >= (n), fmt, ##__VA_ARGS__)
+#define DB_ESS(fmt, ...)                                               \
+       DB_PR(debug.d_ess, fmt, ##__VA_ARGS__)
+#define DB_ESSN(n, fmt, ...)                                           \
+       DB_PR(debug.d_ess >= (n), fmt, ##__VA_ARGS__)
 #endif
 
 #ifndef        SS_NOT_DS
@@ -640,9 +670,12 @@ void dump_smt(struct s_smc *smc, struct smt_header *sm, char *text);
 #define        dump_smt(smc,sm,text)
 #endif
 
-#ifdef DEBUG
+#ifdef DEBUG
 char* addr_to_string(struct fddi_addr *addr);
 void dump_hex(char *p, int len);
+#else
+static inline char *addr_to_string(struct fddi_addr *addr) { return NULL; };
+static inline void dump_hex(char *p, int len) {};
 #endif
 
 #endif /* PROTOTYP_INC */
diff --git a/drivers/net/fddi/skfp/h/osdef1st.h b/drivers/net/fddi/skfp/h/osdef1st.h
index 763ca18..672c5fb 100644
--- a/drivers/net/fddi/skfp/h/osdef1st.h
+++ b/drivers/net/fddi/skfp/h/osdef1st.h
@@ -54,6 +54,8 @@
 
 #ifdef DEBUG
 #define printf(s,args...) printk(KERN_INFO s, ## args)
+#else
+#define printf(s, args...) do { if (0) printk(KERN_INFO s, ## args); } while (0)
 #endif
 
 // #define HW_PTR      u_long
diff --git a/drivers/net/fddi/skfp/pcmplc.c b/drivers/net/fddi/skfp/pcmplc.c
index 88d02d0..3e2151e 100644
--- a/drivers/net/fddi/skfp/pcmplc.c
+++ b/drivers/net/fddi/skfp/pcmplc.c
@@ -91,7 +91,6 @@ int p
 #define PC8_ACTIVE             8
 #define PC9_MAINT              9
 
-#ifdef DEBUG
 /*
  * symbolic state names
  */
@@ -113,7 +112,6 @@ static const char * const pcm_events[] = {
        "PC_TIMEOUT_TL_MIN","PC_TIMEOUT_T_NEXT","PC_TIMEOUT_LCT",
        "PC_NSE","PC_LEM"
 } ;
-#endif
 
 #ifdef MOT_ELM
 /*
@@ -1017,7 +1015,7 @@ static void pcm_fsm(struct s_smc *smc, struct s_phy *phy, int cmd)
                ACTIONS_DONE() ;
                break ;
        case PC9_MAINT :
-               DB_PCMN(1,"PCM %c : MAINT\n",phy->phy_name,0) ;
+               DB_PCMN(1, "PCM %c : MAINT\n", phy->phy_name);
                /*PC90*/
                if (cmd == PC_ENABLE) {
                        GO_STATE(PC0_OFF) ;
@@ -1126,13 +1124,12 @@ static void lem_evaluate(struct s_smc *smc, struct s_phy *phy)
        }
 
        if (lem->lem_errors) {
-               DB_PCMN(1,"LEM %c :\n",phy->np == PB? 'B' : 'A',0) ;
-               DB_PCMN(1,"errors      : %ld\n",lem->lem_errors,0) ;
-               DB_PCMN(1,"sum_errors  : %ld\n",mib->fddiPORTLem_Ct,0) ;
-               DB_PCMN(1,"current BER : 10E-%d\n",ber/100,0) ;
-               DB_PCMN(1,"float BER   : 10E-(%d/100)\n",lem->lem_float_ber,0) ;
-               DB_PCMN(1,"avg. BER    : 10E-%d\n",
-                       mib->fddiPORTLer_Estimate,0) ;
+               DB_PCMN(1, "LEM %c :\n", phy->np == PB ? 'B' : 'A');
+               DB_PCMN(1, "errors      : %ld\n", lem->lem_errors);
+               DB_PCMN(1, "sum_errors  : %ld\n", mib->fddiPORTLem_Ct);
+               DB_PCMN(1, "current BER : 10E-%d\n", ber / 100);
+               DB_PCMN(1, "float BER   : 10E-(%d/100)\n", lem->lem_float_ber);
+               DB_PCMN(1, "avg. BER    : 10E-%d\n", mib->fddiPORTLer_Estimate);
        }
 
        lem->lem_errors = 0L ;
@@ -1213,7 +1210,7 @@ static void lem_check_lct(struct s_smc *smc, struct s_phy *phy)
                                phy->pc_lem_fail = TRUE ;
                        break ;
                }
-               DB_PCMN(1," >>errors : %d\n",lem->lem_errors,0) ;
+               DB_PCMN(1, " >>errors : %lu\n", lem->lem_errors);
        }
        if (phy->pc_lem_fail) {
                mib->fddiPORTLCTFail_Ct++ ;
@@ -1299,7 +1296,7 @@ static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
                if (mib->fddiPORTMy_Type == TM &&
                        mib->fddiPORTNeighborType == TM) {
                        DB_PCMN(1,"PCM %c : E100 withhold M-M\n",
-                               phy->phy_name,0) ;
+                               phy->phy_name);
                        mib->fddiPORTPC_Withhold = PC_WH_M_M ;
                        RS_SET(smc,RS_EVENT) ;
                }
@@ -1322,7 +1319,7 @@ static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
                        mib->fddiPORTPC_Withhold = PC_WH_OTHER ;
                        RS_SET(smc,RS_EVENT) ;
                        DB_PCMN(1,"PCM %c : E101 withhold other\n",
-                               phy->phy_name,0) ;
+                               phy->phy_name);
                }
                phy->twisted = ((mib->fddiPORTMy_Type != TS) &&
                                (mib->fddiPORTMy_Type != TM) &&
@@ -1330,7 +1327,7 @@ static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
                                mib->fddiPORTMy_Type)) ;
                if (phy->twisted) {
                        DB_PCMN(1,"PCM %c : E102 !!! TWISTED !!!\n",
-                               phy->phy_name,0) ;
+                               phy->phy_name);
                }
                break ;
        case 5 :
@@ -1368,7 +1365,7 @@ static void pc_rcode_actions(struct s_smc *smc, int bit, struct s_phy *phy)
                if (phy->t_next[7] > smc->s.pcm_lc_medium) {
                        start_pcm_timer0(smc,phy->t_next[7],PC_TIMEOUT_LCT,phy);
                }
-               DB_PCMN(1,"LCT timer = %ld us\n", phy->t_next[7], 0) ;
+               DB_PCMN(1, "LCT timer = %ld us\n", phy->t_next[7]);
                phy->t_next[9] = smc->s.pcm_t_next_9 ;
                break ;
        case 7:
@@ -1530,7 +1527,7 @@ static void pc_tcode_actions(struct s_smc *smc, const int bit, struct s_phy *phy
                lem_check_lct(smc,phy) ;
                if (phy->pc_lem_fail) {
                        DB_PCMN(1,"PCM %c : E104 LCT failed\n",
-                               phy->phy_name,0) ;
+                               phy->phy_name);
                        phy->t_val[7] = 1 ;
                }
                else
diff --git a/drivers/net/fddi/skfp/pmf.c b/drivers/net/fddi/skfp/pmf.c
index 441b4dc..b69bc86 100644
--- a/drivers/net/fddi/skfp/pmf.c
+++ b/drivers/net/fddi/skfp/pmf.c
@@ -284,7 +284,7 @@ void smt_pmf_received_pack(struct s_smc *smc, SMbuf *mb, int local)
        SMbuf           *reply ;
 
        sm = smtod(mb,struct smt_header *) ;
-       DB_SMT("SMT: processing PMF frame at %x len %d\n",sm,mb->sm_len) ;
+       DB_SMT("SMT: processing PMF frame at %p len %d\n", sm, mb->sm_len);
 #ifdef DEBUG
        dump_smt(smc,sm,"PMF Received") ;
 #endif
diff --git a/drivers/net/fddi/skfp/rmt.c b/drivers/net/fddi/skfp/rmt.c
index ef8d567..67e5c19 100644
--- a/drivers/net/fddi/skfp/rmt.c
+++ b/drivers/net/fddi/skfp/rmt.c
@@ -70,7 +70,6 @@ static const char ID_sccs[] = "@(#)rmt.c      2.13 99/07/02 (C) SK " ;
 #define RM6_DIRECTED   6               /* sending directed beacons */
 #define RM7_TRACE      7               /* trace initiated */
 
-#ifdef DEBUG
 /*
  * symbolic state names
  */
@@ -91,7 +90,6 @@ static const char * const rmt_events[] = {
        "RM_TIMEOUT_ANNOUNCE","RM_TIMEOUT_T_DIRECT",
        "RM_TIMEOUT_D_MAX","RM_TIMEOUT_POLL","RM_TX_STATE_CHANGE"
 } ;
-#endif
 
 /*
  * Globals
@@ -150,9 +148,9 @@ void rmt(struct s_smc *smc, int event)
 
        do {
                DB_RMT("RMT : state %s%s",
-                       (smc->mib.m[MAC0].fddiMACRMTState & AFLAG) ? "ACTIONS " : "",
-                       rmt_states[smc->mib.m[MAC0].fddiMACRMTState & ~AFLAG]) ;
-               DB_RMT(" event %s\n",rmt_events[event],0) ;
+                      (smc->mib.m[MAC0].fddiMACRMTState & AFLAG) ? "ACTIONS " : "",
+                      rmt_states[smc->mib.m[MAC0].fddiMACRMTState & ~AFLAG]);
+               DB_RMT(" event %s\n", rmt_events[event]);
                state = smc->mib.m[MAC0].fddiMACRMTState ;
                rmt_fsm(smc,event) ;
                event = 0 ;
@@ -191,7 +189,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                smc->r.loop_avail = FALSE ;
                smc->r.sm_ma_avail = FALSE ;
                smc->r.no_flag = TRUE ;
-               DB_RMTN(1,"RMT : ISOLATED\n",0,0) ;
+               DB_RMTN(1, "RMT : ISOLATED\n");
                ACTIONS_DONE() ;
                break ;
        case RM0_ISOLATED :
@@ -213,7 +211,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                stop_rmt_timer1(smc) ;
                stop_rmt_timer2(smc) ;
                sm_ma_control(smc,MA_BEACON) ;
-               DB_RMTN(1,"RMT : RING DOWN\n",0,0) ;
+               DB_RMTN(1, "RMT : RING DOWN\n");
                RS_SET(smc,RS_NORINGOP) ;
                smc->r.sm_ma_avail = FALSE ;
                rmt_indication(smc,0) ;
@@ -248,7 +246,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                                else
                        smc->mib.m[MAC0].fddiMACMA_UnitdataAvailable = FALSE ;
                }
-               DB_RMTN(1,"RMT : RING UP\n",0,0) ;
+               DB_RMTN(1, "RMT : RING UP\n");
                RS_CLEAR(smc,RS_NORINGOP) ;
                RS_SET(smc,RS_RINGOPCHANGE) ;
                rmt_indication(smc,1) ;
@@ -285,7 +283,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                start_rmt_timer1(smc,smc->s.rmt_t_stuck,RM_TIMEOUT_T_STUCK) ;
                start_rmt_timer2(smc,smc->s.rmt_t_poll,RM_TIMEOUT_POLL) ;
                sm_mac_check_beacon_claim(smc) ;
-               DB_RMTN(1,"RMT : RM3_DETECT\n",0,0) ;
+               DB_RMTN(1, "RMT : RM3_DETECT\n");
                ACTIONS_DONE() ;
                break ;
        case RM3_DETECT :
@@ -327,7 +325,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                         * trace !
                         */
                        if ((tx =  sm_mac_get_tx_state(smc)) == 4 || tx == 5) {
-                       DB_RMTN(2,"RMT : DETECT && TRT_EXPIRED && T4/T5\n",0,0);
+                               DB_RMTN(2, "RMT : DETECT && TRT_EXPIRED && T4/T5\n");
                                smc->r.bn_flag = TRUE ;
                                /*
                                 * If one of the upstream stations beaconed
@@ -378,7 +376,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                start_rmt_timer1(smc,smc->s.rmt_t_stuck,RM_TIMEOUT_T_STUCK) ;
                start_rmt_timer2(smc,smc->s.rmt_t_poll,RM_TIMEOUT_POLL) ;
                sm_mac_check_beacon_claim(smc) ;
-               DB_RMTN(1,"RMT : RM4_NON_OP_DUP\n",0,0) ;
+               DB_RMTN(1, "RMT : RM4_NON_OP_DUP\n");
                ACTIONS_DONE() ;
                break ;
        case RM4_NON_OP_DUP :
@@ -406,7 +404,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                         * trace !
                         */
                        if ((tx =  sm_mac_get_tx_state(smc)) == 4 || tx == 5) {
-                       DB_RMTN(2,"RMT : NOPDUP && TRT_EXPIRED && T4/T5\n",0,0);
+                               DB_RMTN(2, "RMT : NOPDUP && TRT_EXPIRED && T4/T5\n");
                                smc->r.bn_flag = TRUE ;
                                /*
                                 * If one of the upstream stations beaconed
@@ -448,7 +446,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                stop_rmt_timer0(smc) ;
                stop_rmt_timer1(smc) ;
                stop_rmt_timer2(smc) ;
-               DB_RMTN(1,"RMT : RM5_RING_OP_DUP\n",0,0) ;
+               DB_RMTN(1, "RMT : RM5_RING_OP_DUP\n");
                ACTIONS_DONE() ;
                break;
        case RM5_RING_OP_DUP :
@@ -472,7 +470,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                start_rmt_timer2(smc,smc->s.rmt_t_poll,RM_TIMEOUT_POLL) ;
                sm_ma_control(smc,MA_DIRECTED) ;
                RS_SET(smc,RS_BEACON) ;
-               DB_RMTN(1,"RMT : RM6_DIRECTED\n",0,0) ;
+               DB_RMTN(1, "RMT : RM6_DIRECTED\n");
                ACTIONS_DONE() ;
                break ;
        case RM6_DIRECTED :
@@ -515,7 +513,7 @@ static void rmt_fsm(struct s_smc *smc, int cmd)
                stop_rmt_timer2(smc) ;
                smc->e.trace_prop |= ENTITY_BIT(ENTITY_MAC) ;
                queue_event(smc,EVENT_ECM,EC_TRACE_PROP) ;
-               DB_RMTN(1,"RMT : RM7_TRACE\n",0,0) ;
+               DB_RMTN(1, "RMT : RM7_TRACE\n");
                ACTIONS_DONE() ;
                break ;
        case RM7_TRACE :
diff --git a/drivers/net/fddi/skfp/smt.c b/drivers/net/fddi/skfp/smt.c
index cd78b7c..d941066 100644
--- a/drivers/net/fddi/skfp/smt.c
+++ b/drivers/net/fddi/skfp/smt.c
@@ -35,7 +35,6 @@ static const char ID_sccs[] = "@(#)smt.c      2.43 98/11/23 (C) SK " ;
 
 #define SMT_TID_MAGIC  0x1f0a7b3c
 
-#ifdef DEBUG
 static const char *const smt_type_name[] = {
        "SMT_00??", "SMT_INFO", "SMT_02??", "SMT_03??",
        "SMT_04??", "SMT_05??", "SMT_06??", "SMT_07??",
@@ -47,7 +46,7 @@ static const char *const smt_class_name[] = {
        "UNKNOWN","NIF","SIF_CONFIG","SIF_OPER","ECF","RAF","RDF",
        "SRF","PMF_GET","PMF_SET","ESF"
 } ;
-#endif
+
 #define LAST_CLASS     (SMT_PMF_SET)
 
 static const struct fddi_addr SMT_Unknown = {
@@ -203,7 +202,7 @@ void smt_agent_task(struct s_smc *smc)
 {
        smt_timer_start(smc,&smc->sm.smt_timer, (u_long)1000000L,
                EV_TOKEN(EVENT_SMT,SM_TIMER)) ;
-       DB_SMT("SMT agent task\n",0,0) ;
+       DB_SMT("SMT agent task\n");
 }
 
 #ifndef SMT_REAL_TOKEN_CT
@@ -396,7 +395,7 @@ void smt_event(struct s_smc *smc, int event)
         */
        if (smc->sm.smt_tvu &&
            time - smc->sm.smt_tvu > 228*TICKS_PER_SECOND) {
-               DB_SMT("SMT : UNA expired\n",0,0) ;
+               DB_SMT("SMT : UNA expired\n");
                smc->sm.smt_tvu = 0 ;
 
                if (!is_equal(&smc->mib.m[MAC0].fddiMACUpstreamNbr,
@@ -419,7 +418,7 @@ void smt_event(struct s_smc *smc, int event)
        }
        if (smc->sm.smt_tvd &&
            time - smc->sm.smt_tvd > 228*TICKS_PER_SECOND) {
-               DB_SMT("SMT : DNA expired\n",0,0) ;
+               DB_SMT("SMT : DNA expired\n");
                smc->sm.smt_tvd = 0 ;
                if (!is_equal(&smc->mib.m[MAC0].fddiMACDownstreamNbr,
                        &SMT_Unknown)){
@@ -504,8 +503,8 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
 #endif
 
        smt_swap_para(sm,(int) mb->sm_len,1) ;
-       DB_SMT("SMT : received packet [%s] at 0x%x\n",
-               smt_type_name[m_fc(mb) & 0xf],sm) ;
+       DB_SMT("SMT : received packet [%s] at %p\n",
+              smt_type_name[m_fc(mb) & 0xf], sm);
        DB_SMT("SMT : version %d, class %s\n",sm->smt_version,
                smt_class_name[(sm->smt_class>LAST_CLASS)?0 : sm->smt_class]) ;
 
@@ -525,7 +524,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
         */
        if ( (fs & A_INDICATOR) && m_fc(mb) == FC_SMT_NSA) {
                DB_SMT("SMT : ignoring NSA with A-indicator set from %s\n",
-                       addr_to_string(&sm->smt_source),0) ;
+                       addr_to_string(&sm->smt_source));
                smt_free_mbuf(smc,mb) ;
                return ;
        }
@@ -564,7 +563,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
        }
        if ((sm->smt_len > mb->sm_len - sizeof(struct smt_header)) ||
            ((sm->smt_len & 3) && (sm->smt_class != SMT_ECF))) {
-               DB_SMT("SMT: info length error, len = %d\n",sm->smt_len,0) ;
+               DB_SMT("SMT: info length error, len = %d\n", sm->smt_len);
                smt_send_rdf(smc,mb,m_fc(mb),SMT_RDF_LENGTH,local) ;
                smt_free_mbuf(smc,mb) ;
                return ;
@@ -572,7 +571,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
        switch (sm->smt_class) {
        case SMT_NIF :
                if (smt_check_para(smc,sm,plist_nif)) {
-                       DB_SMT("SMT: NIF with para problem, ignoring\n",0,0) ;
+                       DB_SMT("SMT: NIF with para problem, ignoring\n");
                        break ;
                }
                switch (sm->smt_type) {
@@ -587,7 +586,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                                        &smc->mib.m[MAC0].fddiMACUpstreamNbr,
                                        &sm->smt_source)) {
                                        DB_SMT("SMT : updated my UNA = %s\n",
-                                       addr_to_string(&sm->smt_source),0) ;
+                                       addr_to_string(&sm->smt_source));
                                        if (!is_equal(&smc->mib.m[MAC0].
                                            fddiMACUpstreamNbr,&SMT_Unknown)){
                                         /* Do not update unknown address */
@@ -617,7 +616,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                            ((!(fs & A_INDICATOR) && m_fc(mb) == FC_SMT_NSA) ||
                             (m_fc(mb) != FC_SMT_NSA))) {
                                DB_SMT("SMT : replying to NIF request %s\n",
-                                       addr_to_string(&sm->smt_source),0) ;
+                                       addr_to_string(&sm->smt_source));
                                smt_send_nif(smc,&sm->smt_source,
                                        FC_SMT_INFO,
                                        sm->smt_tid,
@@ -626,10 +625,10 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                        break ;
                case SMT_REPLY :
                        DB_SMT("SMT : received NIF response from %s\n",
-                               addr_to_string(&sm->smt_source),0) ;
+                               addr_to_string(&sm->smt_source));
                        if (fs & A_INDICATOR) {
                                smc->sm.pend[SMT_TID_NIF] = 0 ;
-                               DB_SMT("SMT : duplicate address\n",0,0) ;
+                               DB_SMT("SMT : duplicate address\n");
                                smc->mib.m[MAC0].fddiMACDupAddressTest =
                                        DA_FAILED ;
                                smc->r.dup_addr_test = DA_FAILED ;
@@ -644,7 +643,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                                if (!is_equal(
                                        &smc->mib.m[MAC0].fddiMACDownstreamNbr,
                                        &sm->smt_source)) {
-                                       DB_SMT("SMT : updated my DNA\n",0,0) ;
+                                       DB_SMT("SMT : updated my DNA\n");
                                        if (!is_equal(&smc->mib.m[MAC0].
                                         fddiMACDownstreamNbr, &SMT_Unknown)){
                                         /* Do not update unknown address */
@@ -671,11 +670,11 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                        }
                        else if (sm->smt_tid ==
                                smc->sm.pend[SMT_TID_NIF_TEST]) {
-                               DB_SMT("SMT : NIF test TID ok\n",0,0) ;
+                               DB_SMT("SMT : NIF test TID ok\n");
                        }
                        else {
-                               DB_SMT("SMT : expected TID %lx, got %lx\n",
-                               smc->sm.pend[SMT_TID_NIF],sm->smt_tid) ;
+                               DB_SMT("SMT : expected TID %lx, got %x\n",
+                                      smc->sm.pend[SMT_TID_NIF], sm->smt_tid);
                        }
                        break ;
                default :
@@ -687,14 +686,14 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                if (sm->smt_type != SMT_REQUEST)
                        break ;
                DB_SMT("SMT : replying to SIF Config request from %s\n",
-                       addr_to_string(&sm->smt_source),0) ;
+                       addr_to_string(&sm->smt_source));
                smt_send_sif_config(smc,&sm->smt_source,sm->smt_tid,local) ;
                break ;
        case SMT_SIF_OPER :     /* station information */
                if (sm->smt_type != SMT_REQUEST)
                        break ;
                DB_SMT("SMT : replying to SIF Operation request from %s\n",
-                       addr_to_string(&sm->smt_source),0) ;
+                       addr_to_string(&sm->smt_source));
                smt_send_sif_operation(smc,&sm->smt_source,sm->smt_tid,local) ;
                break ;
        case SMT_ECF :          /* echo frame */
@@ -702,37 +701,36 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                case SMT_REPLY :
                        smc->mib.priv.fddiPRIVECF_Reply_Rx++ ;
                        DB_SMT("SMT: received ECF reply from %s\n",
-                               addr_to_string(&sm->smt_source),0) ;
+                               addr_to_string(&sm->smt_source));
                        if (sm_to_para(smc,sm,SMT_P_ECHODATA) == NULL) {
-                               DB_SMT("SMT: ECHODATA missing\n",0,0) ;
+                               DB_SMT("SMT: ECHODATA missing\n");
                                break ;
                        }
                        if (sm->smt_tid == smc->sm.pend[SMT_TID_ECF]) {
-                               DB_SMT("SMT : ECF test TID ok\n",0,0) ;
+                               DB_SMT("SMT : ECF test TID ok\n");
                        }
                        else if (sm->smt_tid == smc->sm.pend[SMT_TID_ECF_UNA]) {
-                               DB_SMT("SMT : ECF test UNA ok\n",0,0) ;
+                               DB_SMT("SMT : ECF test UNA ok\n");
                        }
                        else if (sm->smt_tid == smc->sm.pend[SMT_TID_ECF_DNA]) {
-                               DB_SMT("SMT : ECF test DNA ok\n",0,0) ;
+                               DB_SMT("SMT : ECF test DNA ok\n");
                        }
                        else {
-                               DB_SMT("SMT : expected TID %lx, got %lx\n",
-                                       smc->sm.pend[SMT_TID_ECF],
-                                       sm->smt_tid) ;
+                               DB_SMT("SMT : expected TID %lx, got %x\n",
+                                      smc->sm.pend[SMT_TID_ECF], sm->smt_tid);
                        }
                        break ;
                case SMT_REQUEST :
                        smc->mib.priv.fddiPRIVECF_Req_Rx++ ;
                        {
                        if (sm->smt_len && !sm_to_para(smc,sm,SMT_P_ECHODATA)) {
-                       DB_SMT("SMT: ECF with para problem,sending RDF\n",0,0) ;
+                               DB_SMT("SMT: ECF with para problem,sending RDF\n");
                                smt_send_rdf(smc,mb,m_fc(mb),SMT_RDF_LENGTH,
                                        local) ;
                                break ;
                        }
                        DB_SMT("SMT - sending ECF reply to %s\n",
-                               addr_to_string(&sm->smt_source),0) ;
+                               addr_to_string(&sm->smt_source));
 
                        /* set destination addr.  & reply */
                        sm->smt_dest = sm->smt_source ;
@@ -750,7 +748,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
 #ifndef        BOOT
        case SMT_RAF :          /* resource allocation */
 #ifdef ESS
-               DB_ESSN(2,"ESS: RAF frame received\n",0,0) ;
+               DB_ESSN(2, "ESS: RAF frame received\n");
                fs = ess_raf_received_pack(smc,mb,sm,fs) ;
 #endif
 
@@ -764,7 +762,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                break ;
        case SMT_ESF :          /* extended service - not supported */
                if (sm->smt_type == SMT_REQUEST) {
-                       DB_SMT("SMT - received ESF, sending RDF\n",0,0) ;
+                       DB_SMT("SMT - received ESF, sending RDF\n");
                        smt_send_rdf(smc,mb,m_fc(mb),SMT_RDF_CLASS,local) ;
                }
                break ;
@@ -782,7 +780,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
                 */
                if ((sm->smt_class == SMT_PMF_SET) &&
                        !is_individual(&sm->smt_dest)) {
-                       DB_SMT("SMT: ignoring PMF-SET with I/G set\n",0,0) ;
+                       DB_SMT("SMT: ignoring PMF-SET with I/G set\n");
                        break ;
                }
                smt_pmf_received_pack(smc,mb, local) ;
@@ -807,7 +805,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
        }
        if (illegal) {
                DB_SMT("SMT: discarding invalid frame, reason = %d\n",
-                       illegal,0) ;
+                      illegal);
        }
        smt_free_mbuf(smc,mb) ;
 }
@@ -1653,7 +1651,7 @@ int smt_check_para(struct s_smc *smc, struct smt_header   *sm,
        const u_short           *p = list ;
        while (*p) {
                if (!sm_to_para(smc,sm,(int) *p)) {
-                       DB_SMT("SMT: smt_check_para - missing para %x\n",*p,0);
+                       DB_SMT("SMT: smt_check_para - missing para %x\n", *p);
                        return -1;
                }
                p++ ;
@@ -1679,11 +1677,11 @@ void *sm_to_para(struct s_smc *smc, struct smt_header *sm, int para)
                p += plen ;
                len -= plen ;
                if (len < 0) {
-                       DB_SMT("SMT : sm_to_para - length error %d\n",plen,0) ;
+                       DB_SMT("SMT : sm_to_para - length error %d\n", plen);
                        return NULL;
                }
                if ((plen & 3) && (para != SMT_P_ECHODATA)) {
-                       DB_SMT("SMT : sm_to_para - odd length %d\n",plen,0) ;
+                       DB_SMT("SMT : sm_to_para - odd length %d\n", plen);
                        return NULL;
                }
                if (found)
diff --git a/drivers/net/fddi/skfp/srf.c b/drivers/net/fddi/skfp/srf.c
index 9956680..d91963d 100644
--- a/drivers/net/fddi/skfp/srf.c
+++ b/drivers/net/fddi/skfp/srf.c
@@ -173,7 +173,6 @@ static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index)
 #define THRESHOLD_2    (2*TICKS_PER_SECOND)
 #define THRESHOLD_32   (32*TICKS_PER_SECOND)
 
-#ifdef DEBUG
 static const char * const srf_names[] = {
        "None","MACPathChangeEvent",    "MACNeighborChangeEvent",
        "PORTPathChangeEvent",          "PORTUndesiredConnectionAttemptEvent",
@@ -182,7 +181,6 @@ static const char * const srf_names[] = {
        "MACNotCopiedCondition",        "PORTEBErrorCondition",
        "PORTLerCondition"
 } ;
-#endif
 
 void smt_srf_event(struct s_smc *smc, int code, int index, int cond)
 {
@@ -201,7 +199,7 @@ void smt_srf_event(struct s_smc *smc, int code, int index, int cond)
                DB_SMT("SRF: %s index %d\n",srf_names[code],index) ;
 
                if (!(evc = smt_get_evc(smc,code,index))) {
-                       DB_SMT("SRF : smt_get_evc() failed\n",0,0) ;
+                       DB_SMT("SRF : smt_get_evc() failed\n");
                        return ;
                }
                /*
@@ -217,7 +215,7 @@ void smt_srf_event(struct s_smc *smc, int code, int index, int cond)
                 */
                smt_set_timestamp(smc,smc->mib.fddiSMTTransitionTimeStamp) ;
                if (SMT_IS_CONDITION(code)) {
-                       DB_SMT("SRF: condition is %s\n",cond ? "ON":"OFF",0) ;
+                       DB_SMT("SRF: condition is %s\n", cond ? "ON" : "OFF");
                        if (cond) {
                                *evc->evc_cond_state = TRUE ;
                                evc->evc_rep_required = TRUE ;
@@ -414,9 +412,9 @@ static void smt_send_srf(struct s_smc *smc)
        smt->smt_len = SMT_MAX_INFO_LEN - pcon.pc_len ;
        mb->sm_len = smt->smt_len + sizeof(struct smt_header) ;
 
-       DB_SMT("SRF: sending SRF at %p, len %d\n",smt,mb->sm_len) ;
-       DB_SMT("SRF: state SR%d Threshold %d\n",
-               smc->srf.sr_state,smc->srf.SRThreshold/TICKS_PER_SECOND) ;
+       DB_SMT("SRF: sending SRF at %p, len %d\n", smt, mb->sm_len);
+       DB_SMT("SRF: state SR%d Threshold %lu\n",
+              smc->srf.sr_state, smc->srf.SRThreshold / TICKS_PER_SECOND);
 #ifdef DEBUG
        dump_smt(smc,smt,"SRF Send") ;
 #endif
