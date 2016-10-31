From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] genetlink: fix error return code in genl_register_family()
Date: Mon, 31 Oct 2016 14:53:03 +0000
Message-ID: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: stephen hemminger <stephen@networkplumber.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tom Herbert <tom@herbertland.com>,
        Johannes Berg <johannes.berg@intel.com>,
        pravin shelar <pshelar@ovn.org>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33382 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943611AbcJaOxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 10:53:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id a136so5559008pfa.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 07:53:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -ENOMEM from the idr_alloc() error handling
case instead of 0, as done elsewhere in this function.

Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/netlink/genetlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index caf04d7..305730d 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -362,8 +362,10 @@ int genl_register_family(struct genl_family *family)
 
 	family->id = idr_alloc(&genl_fam_idr, family,
 			       start, end + 1, GFP_KERNEL);
-	if (!family->id)
+	if (!family->id) {
+		err = -ENOMEM;
 		goto errout_locked;
+	}
 
 	err = genl_validate_assign_mc_groups(family);
 	if (err)
