From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/3] tc: flower: No need to cache indev arg
Date: Tue, 26 Sep 2017 18:35:47 +0200
Message-ID: <20170926163548.24347-3-phil@nwl.cc>
References: <20170926163548.24347-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58160 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966076AbdIZQ4z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 12:56:55 -0400
In-Reply-To: <20170926163548.24347-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since addattrstrz() will copy the provided string into the attribute
payload, there is no need to cache the data.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/f_flower.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 934832e2bbe90..99e62a382dec6 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -629,11 +629,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 		} else if (matches(*argv, "skip_sw") == 0) {
 			flags |= TCA_CLS_FLAGS_SKIP_SW;
 		} else if (matches(*argv, "indev") == 0) {
-			char ifname[IFNAMSIZ] = {};
-
 			NEXT_ARG();
-			strncpy(ifname, *argv, sizeof(ifname) - 1);
-			addattrstrz(n, MAX_MSG, TCA_FLOWER_INDEV, ifname);
+			addattrstrz(n, MAX_MSG, TCA_FLOWER_INDEV, *argv);
 		} else if (matches(*argv, "vlan_id") == 0) {
 			__u16 vid;
 
-- 
2.13.1
