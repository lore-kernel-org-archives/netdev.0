From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 2/3] ss: enable query by type in unix domain related socket
Date: Wed,  8 Jan 2014 20:13:47 +0900
Message-ID: <1389179628-22147-2-git-send-email-yamato@redhat.com>
References: <1389179628-22147-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755903AbaAHLOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 06:14:11 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s08BEApo008436
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 8 Jan 2014 06:14:11 -0500
In-Reply-To: <1389179628-22147-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables -A unix_stream, -A unix_dgram and
-A unix_seqpacket option even if ss gets socket information
via netlink.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 misc/ss.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index bac1f9e..cea3f2e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2205,6 +2205,13 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
+	if (r->udiag_type == SOCK_STREAM && !(f->dbs&(1<<UNIX_ST_DB)))
+		return 0;
+	if (r->udiag_type == SOCK_DGRAM && !(f->dbs&(1<<UNIX_DG_DB)))
+		return 0;
+	if (r->udiag_type == SOCK_SEQPACKET && !(f->dbs&(1<<UNIX_SQ_DB)))
+		return 0;
+
 	if (netid_width)
 		printf("%-*s ", netid_width,
 		       		unix_netid_name(r->udiag_type));
-- 
1.8.4.2
