From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 11/15] stm class: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:50 +0200
Message-ID: <1508167134-6243-12-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@redh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:57262 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbdJPPTj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:19:39 -0400
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make config_item_type structures const as they are either passed to a
function having the argument as const or used inside a if statement or
stored in the const "ci_type" field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/hwtracing/stm/policy.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/hwtracing/stm/policy.c b/drivers/hwtracing/stm/policy.c
index 6c0ae29..33e9a1b 100644
--- a/drivers/hwtracing/stm/policy.c
+++ b/drivers/hwtracing/stm/policy.c
@@ -187,8 +187,8 @@ static void stp_policy_node_release(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type stp_policy_type;
-static struct config_item_type stp_policy_node_type;
+static const struct config_item_type stp_policy_type;
+static const struct config_item_type stp_policy_node_type;
 
 static struct config_group *
 stp_policy_node_make(struct config_group *group, const char *name)
@@ -236,7 +236,7 @@ static void stp_policy_node_release(struct config_item *item)
 	.drop_item	= stp_policy_node_drop,
 };
 
-static struct config_item_type stp_policy_node_type = {
+static const struct config_item_type stp_policy_node_type = {
 	.ct_item_ops	= &stp_policy_node_item_ops,
 	.ct_group_ops	= &stp_policy_node_group_ops,
 	.ct_attrs	= stp_policy_node_attrs,
@@ -311,7 +311,7 @@ static void stp_policy_release(struct config_item *item)
 	.make_group	= stp_policy_node_make,
 };
 
-static struct config_item_type stp_policy_type = {
+static const struct config_item_type stp_policy_type = {
 	.ct_item_ops	= &stp_policy_item_ops,
 	.ct_group_ops	= &stp_policy_group_ops,
 	.ct_attrs	= stp_policy_attrs,
@@ -380,7 +380,7 @@ static void stp_policy_release(struct config_item *item)
 	.make_group	= stp_policies_make,
 };
 
-static struct config_item_type stp_policies_type = {
+static const struct config_item_type stp_policies_type = {
 	.ct_group_ops	= &stp_policies_group_ops,
 	.ct_owner	= THIS_MODULE,
 };
-- 
1.9.1
