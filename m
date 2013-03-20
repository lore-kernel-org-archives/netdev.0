From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] openvswitch: fix error return code in ovs_vport_cmd_set()
Date: Wed, 20 Mar 2013 20:14:53 +0800
Message-ID: <CAPgLHd_6+xnMKZBzH3KySpFv7hUzzNot7GBYSCAPLDRbC5HjsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, dev@openvswitch.org,
	netdev@vger.kernel.org
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:52746 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226Ab3CTMOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 08:14:55 -0400
Received: by mail-bk0-f51.google.com with SMTP id ik5so806887bkc.38
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 05:14:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/openvswitch/datapath.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d61cd99..1ee11c3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1736,6 +1736,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
+	err = PTR_ERR(reply);
 	if (IS_ERR(reply)) {
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_vport_multicast_group.id, PTR_ERR(reply));
