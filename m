From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 3/5] openvswitch: Fix ovs_dp_cmd_msg_size()
Date: Tue,  4 Feb 2014 22:59:19 -0800
Message-ID: <1391583561-25399-4-git-send-email-jesse@nicira.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Daniele Di Proietto <daniele.di.proietto@gmail.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:35250 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932174AbaBEG7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 01:59:32 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so9595658pad.36
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 22:59:32 -0800 (PST)
In-Reply-To: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Di Proietto <daniele.di.proietto@gmail.com>

commit 43d4be9cb55f3bac5253e9289996fd9d735531db (openvswitch: Allow user space
to announce ability to accept unaligned Netlink messages) introduced
OVS_DP_ATTR_USER_FEATURES netlink attribute in datapath responses,
but the attribute size was not taken into account in ovs_dp_cmd_msg_size().

Signed-off-by: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e1b337e..58689dd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1087,6 +1087,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 	msgsize += nla_total_size(IFNAMSIZ);
 	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
 	msgsize += nla_total_size(sizeof(struct ovs_dp_megaflow_stats));
+	msgsize += nla_total_size(sizeof(u32)); /* OVS_DP_ATTR_USER_FEATURES */
 
 	return msgsize;
 }
-- 
1.8.3.2
