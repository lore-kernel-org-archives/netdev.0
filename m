From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [RFC net-next 1/5] net/sched: Introduce the user API for the CBS shaper
Date: Thu, 31 Aug 2017 18:26:21 -0700
Message-ID: <20170901012625.14838-2-vinicius.gomes@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20239 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750996AbdIAB03 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 21:26:29 -0400
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the API necessary for configuring the CBS shaper (implemented
in the next patch) via the tc tool.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 include/uapi/linux/pkt_sched.h | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf5528fed..aa4a3e5421be 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -871,4 +871,33 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* CBS */
+/* FIXME: this is only for usage with ndo_setup_tc(), this should be
+ * in another header someplace else. Is pkt_cls.h the right place?
+ */
+struct tc_cbs_qopt_offload {
+	u8		enable;
+	s32		queue;
+	s32		hicredit;
+	s32		locredit;
+	s32		idleslope;
+	s32		sendslope;
+};
+
+struct tc_cbs_qopt {
+	__s32		hicredit;
+	__s32		locredit;
+	__s32		idleslope;
+	__s32		sendslope;
+};
+
+enum {
+	TCA_CBS_UNSPEC,
+	TCA_CBS_PARMS,
+	__TCA_CBS_MAX,
+};
+
+#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)
+
 #endif
-- 
2.14.1
