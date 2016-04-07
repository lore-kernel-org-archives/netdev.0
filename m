From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 2/4] vxlan: 'external' implies 'nolearning'
Date: Thu,  7 Apr 2016 14:36:27 +0200
Message-ID: <69b482ba436939499e2d336849b297c0c9a8e6d3.1460032274.git.jbenc@redhat.com>
References: <cover.1460032274.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756081AbcDGMhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 08:37:22 -0400
In-Reply-To: <cover.1460032274.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't make sense to use external control plane and fill internal FDB at
the same time. It's even an illegal combination for VXLAN-GPE.

Just switch off learning when 'external' is specified.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/iplink_vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index e3bbea0031df..e9d64b451677 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -234,6 +234,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			remcsumrx = 0;
 		} else if (!matches(*argv, "external")) {
 			metadata = 1;
+			learning = 0;
 		} else if (!matches(*argv, "noexternal")) {
 			metadata = 0;
 		} else if (!matches(*argv, "gbp")) {
-- 
1.8.3.1
