From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v4 1/6] cls_flower: Offload classid to
 hardware
Date: Tue, 10 Oct 2017 17:24:17 -0700
Message-ID: <150768145789.5320.12630174072579962718.stgit@anamdev.jf.intel.com>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58302 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754392AbdJKAZn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:25:43 -0400
In-Reply-To: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The classid on a filter is used to match a packet to a class.
tcf_result structure contains the class ID of the class to which
the packet belongs. This patch enables offloading the classid to
the hardware.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/net/pkt_cls.h  |    1 +
 net/sched/cls_flower.c |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 456017a..c2f847f 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -515,6 +515,7 @@ struct tc_cls_flower_offload {
 	struct fl_flow_key *key;
 	struct tcf_exts *exts;
 	bool egress_dev;
+	u32 classid;
 };
 
 enum tc_matchall_command {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index db831ac..50c8a52 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -241,6 +241,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	cls_flower.mask = mask;
 	cls_flower.key = &f->mkey;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 					    &cls_flower);
@@ -264,6 +265,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.command = TC_CLSFLOWER_STATS;
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 				      &cls_flower);
