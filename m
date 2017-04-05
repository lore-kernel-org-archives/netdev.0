From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/7] s390/qeth: Remove unused code
Date: Wed,  5 Apr 2017 10:40:12 +0200
Message-ID: <20170405084015.35772-5-ubraun@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43275 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754406AbdDEIke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:34 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358dQhY088444
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:33 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29mr5sbnf3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:33 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:31 +0100
In-Reply-To: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

1. options.add_hhlen is set but never used, drop it
2. clean up no longer required forward declarations
3. delete all sorts of unused defines

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  5 -----
 drivers/s390/net/qeth_core_main.c |  2 --
 drivers/s390/net/qeth_core_mpc.h  | 17 -----------------
 drivers/s390/net/qeth_l2_main.c   |  1 -
 drivers/s390/net/qeth_l2_sys.c    |  3 ---
 drivers/s390/net/qeth_l3_main.c   |  4 ----
 6 files changed, 32 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 77f7cfd..22aa2cd 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -509,9 +509,6 @@ struct qeth_qdio_info {
 #define QETH_TR_MAC_NC       0xc000 /* non-canonical */
 #define QETH_TR_MAC_C        0x0300 /* canonical */
 
-#define DEFAULT_ADD_HHLEN 0
-#define MAX_ADD_HHLEN 1024
-
 /**
  * buffer stuff for read channel
  */
@@ -637,7 +634,6 @@ struct qeth_reply {
 	atomic_t refcnt;
 };
 
-
 struct qeth_card_blkt {
 	int time_total;
 	int inter_packet;
@@ -678,7 +674,6 @@ struct qeth_card_options {
 	struct qeth_ipa_info ipa6;
 	struct qeth_sbp_info sbp; /* SETBRIDGEPORT options */
 	int fake_broadcast;
-	int add_hhlen;
 	int layer2;
 	int performance_stats;
 	int rx_sg_cb;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 639b92b..194f9d8 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -55,7 +55,6 @@ static struct mutex qeth_mod_mutex;
 
 static void qeth_send_control_data_cb(struct qeth_channel *,
 			struct qeth_cmd_buffer *);
-static int qeth_issue_next_read(struct qeth_card *);
 static struct qeth_cmd_buffer *qeth_get_buffer(struct qeth_channel *);
 static void qeth_setup_ccw(struct qeth_channel *, unsigned char *, __u32);
 static void qeth_free_buffer_pool(struct qeth_card *);
@@ -1396,7 +1395,6 @@ static void qeth_set_intial_options(struct qeth_card *card)
 	card->options.route4.type = NO_ROUTER;
 	card->options.route6.type = NO_ROUTER;
 	card->options.fake_broadcast = 0;
-	card->options.add_hhlen = DEFAULT_ADD_HHLEN;
 	card->options.performance_stats = 0;
 	card->options.rx_sg_cb = QETH_RX_SG_CB;
 	card->options.isolation = ISOLATION_MODE_NONE;
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index bc69d0a..4accb0a 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -29,7 +29,6 @@ extern unsigned char IPA_PDU_HEADER[];
 #define QETH_TIMEOUT		(10 * HZ)
 #define QETH_IPA_TIMEOUT	(45 * HZ)
 #define QETH_IDX_COMMAND_SEQNO	0xffff0000
-#define SR_INFO_LEN		16
 
 #define QETH_CLEAR_CHANNEL_PARM	-10
 #define QETH_HALT_CHANNEL_PARM	-11
@@ -65,7 +64,6 @@ enum qeth_link_types {
 	QETH_LINK_TYPE_LANE_TR      = 0x82,
 	QETH_LINK_TYPE_LANE_ETH1000 = 0x83,
 	QETH_LINK_TYPE_LANE         = 0x88,
-	QETH_LINK_TYPE_ATM_NATIVE   = 0x90,
 };
 
 /*
@@ -185,8 +183,6 @@ enum qeth_ipa_return_codes {
 	IPA_RC_ENOMEM			= 0xfffe,
 	IPA_RC_FFFF			= 0xffff
 };
-/* for DELIP */
-#define IPA_RC_IP_ADDRESS_NOT_DEFINED	IPA_RC_PRIMARY_ALREADY_DEFINED
 /* for SET_DIAGNOSTIC_ASSIST */
 #define IPA_RC_INVALID_SUBCMD		IPA_RC_IP_TABLE_FULL
 #define IPA_RC_HARDWARE_AUTH_ERROR	IPA_RC_UNKNOWN_ERROR
@@ -631,14 +627,6 @@ enum qeth_ipa_addr_change_code {
 	IPA_ADDR_CHANGE_CODE_MACADDR		= 0x02,
 	IPA_ADDR_CHANGE_CODE_REMOVAL		= 0x80,	/* else addition */
 };
-enum qeth_ipa_addr_change_retcode {
-	IPA_ADDR_CHANGE_RETCODE_OK		= 0x0000,
-	IPA_ADDR_CHANGE_RETCODE_LOSTEVENTS	= 0x0010,
-};
-enum qeth_ipa_addr_change_lostmask {
-	IPA_ADDR_CHANGE_MASK_OVERFLOW		= 0x01,
-	IPA_ADDR_CHANGE_MASK_STATECHANGE	= 0x02,
-};
 
 struct qeth_ipacmd_addr_change_entry {
 	struct net_if_token token;
@@ -817,9 +805,4 @@ extern unsigned char IDX_ACTIVATE_WRITE[];
 	((buffer) && \
 	 (*(buffer + ((*(buffer + 0x0b)) + 4)) == 0xc1))
 
-#define ADDR_FRAME_TYPE_DIX 1
-#define ADDR_FRAME_TYPE_802_3 2
-#define ADDR_FRAME_TYPE_TR_WITHOUT_SR 0x10
-#define ADDR_FRAME_TYPE_TR_WITH_SR 0x20
-
 #endif
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index bea4833..5917982 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -28,7 +28,6 @@
 static int qeth_l2_set_offline(struct ccwgroup_device *);
 static int qeth_l2_stop(struct net_device *);
 static void qeth_l2_set_rx_mode(struct net_device *);
-static int qeth_l2_recover(void *);
 static void qeth_bridgeport_query_support(struct qeth_card *card);
 static void qeth_bridge_state_change(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 692db49..6879723 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -8,9 +8,6 @@
 #include "qeth_core.h"
 #include "qeth_l2.h"
 
-#define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
-struct device_attribute dev_attr_##_id = __ATTR(_name, _mode, _show, _store)
-
 static ssize_t qeth_bridge_port_role_state_show(struct device *dev,
 				struct device_attribute *attr, char *buf,
 				int show_state)
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 06d0add..8de5f74 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -36,16 +36,12 @@
 
 
 static int qeth_l3_set_offline(struct ccwgroup_device *);
-static int qeth_l3_recover(void *);
 static int qeth_l3_stop(struct net_device *);
 static void qeth_l3_set_multicast_list(struct net_device *);
-static int qeth_l3_neigh_setup(struct net_device *, struct neigh_parms *);
 static int qeth_l3_register_addr_entry(struct qeth_card *,
 		struct qeth_ipaddr *);
 static int qeth_l3_deregister_addr_entry(struct qeth_card *,
 		struct qeth_ipaddr *);
-static int __qeth_l3_set_online(struct ccwgroup_device *, int);
-static int __qeth_l3_set_offline(struct ccwgroup_device *, int);
 
 static int qeth_l3_isxdigit(char *buf)
 {
-- 
2.10.2
