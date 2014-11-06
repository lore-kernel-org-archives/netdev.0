From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] dcbnl : Fix lock initialization
Date: Thu,  6 Nov 2014 10:09:15 -0800
Message-ID: <1415297355-27282-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, john.r.fastabend@intel.com,
	ying.xue@windriver.com, jeffrey.t.kirsher@intel.com,
	ebiederm@xmission.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:60929
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750970AbaKFSOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:14:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dcb_lock was being used uninitialized in dcbnl and is infact missing
 initialization code. Fixed

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 net/dcb/dcbnl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ca11d28..7bc44e1 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1914,6 +1914,8 @@ static int __init dcbnl_init(void)
 {
 	INIT_LIST_HEAD(&dcb_app_list);
 
+	spin_lock_init(&dcb_lock);
+
 	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL, NULL);
 
-- 
2.1.3
