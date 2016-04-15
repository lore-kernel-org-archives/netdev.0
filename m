From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 04/11] devlink: introduce pr_out_port_handle helper
Date: Fri, 15 Apr 2016 09:51:46 +0200
Message-ID: <1460706713-5942-5-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35898 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbcDOHwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:07 -0400
Received: by mail-wm0-f43.google.com with SMTP id v188so19288713wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:01 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 39f423a..0904e07 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -523,6 +523,12 @@ static void pr_out_handle(struct nlattr **tb)
 			mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]));
 }
 
+static void pr_out_port_handle(struct nlattr **tb)
+{
+	pr_out_handle(tb);
+	pr_out("/%d", mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+}
+
 static void pr_out_dev(struct nlattr **tb)
 {
 	pr_out_handle(tb);
@@ -599,8 +605,8 @@ static void pr_out_port(struct nlattr **tb)
 	struct nlattr *pt_attr = tb[DEVLINK_ATTR_PORT_TYPE];
 	struct nlattr *dpt_attr = tb[DEVLINK_ATTR_PORT_DESIRED_TYPE];
 
-	pr_out_handle(tb);
-	pr_out("/%d:", mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+	pr_out_port_handle(tb);
+	pr_out(":");
 	if (pt_attr) {
 		uint16_t port_type = mnl_attr_get_u16(pt_attr);
 
-- 
2.5.5
