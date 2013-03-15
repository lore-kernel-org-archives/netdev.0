From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 1/6] openvswitch: Fix ovs_vport_cmd_del return value on success
Date: Thu, 14 Mar 2013 17:15:01 -0700
Message-ID: <1363306506-885-2-git-send-email-jesse@nicira.com>
References: <1363306506-885-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Rich Lane <rlane@bigswitch.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:35946 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751420Ab3COAPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 20:15:13 -0400
Received: by mail-yh0-f69.google.com with SMTP id w68so3984060yhw.8
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 17:15:12 -0700 (PDT)
In-Reply-To: <1363306506-885-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rich Lane <rlane@bigswitch.com>

If the pointer does not represent an error then the PTR_ERR macro may still
return a nonzero value. The fix is the same as in ovs_vport_cmd_set.

Signed-off-by: Rich Lane <rlane@bigswitch.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f996db3..5e275b9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1772,6 +1772,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(reply))
 		goto exit_unlock;
 
+	err = 0;
 	ovs_dp_detach_port(vport);
 
 	genl_notify(reply, genl_info_net(info), info->snd_portid,
-- 
1.7.10.4
