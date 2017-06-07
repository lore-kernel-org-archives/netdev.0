From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] net: Zero ifla_vf_info in rtnl_fill_vfinfo()
Date: Wed, 7 Jun 2017 21:00:33 +0300
Message-ID: <20170607180033.19747-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Michal Schmidt <mschmidt@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0087.outbound.protection.outlook.com ([104.47.33.87]:26603
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751491AbdFGSBg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 14:01:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the structure's fields are not initialized by the
rtnetlink. If driver doesn't set those in ndo_get_vf_config(),
they'd leak memory to user.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
CC: Michal Schmidt <mschmidt@redhat.com>
---
 net/core/rtnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9e2c0a7..5e61456 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1124,6 +1124,8 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	struct ifla_vf_mac vf_mac;
 	struct ifla_vf_info ivi;
 
+	memset(&ivi, 0, sizeof(ivi));
+
 	/* Not all SR-IOV capable drivers support the
 	 * spoofcheck and "RSS query enable" query.  Preset to
 	 * -1 so the user space tool can detect that the driver
@@ -1132,7 +1134,6 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	ivi.spoofchk = -1;
 	ivi.rss_query_en = -1;
 	ivi.trusted = -1;
-	memset(ivi.mac, 0, sizeof(ivi.mac));
 	/* The default value for VF link state is "auto"
 	 * IFLA_VF_LINK_STATE_AUTO which equals zero
 	 */
-- 
2.9.4
