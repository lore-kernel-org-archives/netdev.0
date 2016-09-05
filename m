From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 2/2] vxlan: group address requires net device
Date: Mon,  5 Sep 2016 11:35:28 +0200
Message-ID: <339db8bf7d0b0bdc9dc69209f4d1d00d45f4132d.1473067954.git.jbenc@redhat.com>
References: <cover.1473067954.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932638AbcIEJfv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 05:35:51 -0400
In-Reply-To: <cover.1473067954.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is now enforced in the kernel, check also in iproute to get a better
error message.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/iplink_vxlan.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 251d3f1cfb0b..93af979a1e97 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -266,6 +266,11 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		return -1;
 	}
 
+	if ((gaddr || !IN6_IS_ADDR_UNSPECIFIED(&gaddr6)) && !link) {
+		fprintf(stderr, "vxlan: 'group' requires 'dev' to be specified\n");
+		return -1;
+	}
+
 	if (!dst_port_set && gpe) {
 		dstport = 4790;
 	} else if (!dst_port_set) {
-- 
1.8.3.1
