From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] openvswitch: use -EEXIST as return error to be more precise
Date: Tue, 28 May 2013 14:31:16 +0800
Message-ID: <1369722676-7898-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34433 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008Ab3E1Gbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:31:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ovs_vport_cmd_new create a new vport with port num specified by user.
when this port num is already occupied, it's more clear to return
-EEXIST as the reason than -EBUSY.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/openvswitch/datapath.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..1e31095 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1755,7 +1755,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 			goto exit_unlock;
 
 		vport = ovs_vport_ovsl(dp, port_no);
-		err = -EBUSY;
+		err = -EEXIST;
 		if (vport)
 			goto exit_unlock;
 	} else {
-- 
1.7.1
