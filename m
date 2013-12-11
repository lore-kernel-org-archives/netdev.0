From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 2/2] Handle netdev group for veth peer too
Date: Wed, 11 Dec 2013 14:25:07 +0200
Message-ID: <2346820.DCsCcedb3C@tuxracer>
References: <cover.1386764590.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.mail.ru ([94.100.176.177]:39693 "EHLO smtp24.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab3LKM3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 07:29:52 -0500
Received: from [2a01:6d80:103:13::c3ea:4404] (port=48239 helo=tuxracer.localnet)
	by smtp24.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1VqivG-00057S-GB
	for netdev@vger.kernel.org; Wed, 11 Dec 2013 16:29:50 +0400
In-Reply-To: <cover.1386764590.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ip-link(8) parses, but ignores "group" argument to
peer interface on veth creation.

Insert IFLA_GROUP attribute for peer interface when present.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 ip/link_veth.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/link_veth.c b/ip/link_veth.c
index 7730f39..98ff6a5 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -53,6 +53,9 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(hdr, 1024, IFLA_IFNAME, name, len);
 	}
 
+	if (group != -1)
+		addattr32(hdr, 1024, IFLA_GROUP, group);
+
 	data->rta_len = (void *)NLMSG_TAIL(hdr) - (void *)data;
 	return argc - 1 - err;
 }
-- 
1.7.10.4
