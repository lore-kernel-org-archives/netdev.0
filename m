From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Reset key metadata for packet execution.
Date: Tue, 10 Feb 2015 13:35:16 -0800
Message-ID: <1423604116-1438-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:57042 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751295AbbBJVfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 16:35:25 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so15272137pab.3
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 13:35:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace packet execute command pass down flow key for given
packet. But userspace can skip some parameter with zero value.
Therefore kernel needs to initialize key metadata to zero.

Fixes: 0714812134 ("openvswitch: Eliminate memset() from flow_extract.")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index da2fae0..5e41bf2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -717,6 +717,8 @@ int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 {
 	int err;
 
+ 	memset(key, 0, OVS_SW_FLOW_KEY_METADATA_SIZE);
+
 	/* Extract metadata from netlink attributes. */
 	err = ovs_nla_get_flow_metadata(attr, key, log);
 	if (err)
-- 
1.7.1
