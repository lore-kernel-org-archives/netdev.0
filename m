From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 4/3] rtnetlink: ignore NETDEV_RELEASE and NETDEV_JOIN event
Date: Fri, 20 May 2011 17:06:32 +0800
Message-ID: <1305882392-21241-1-git-send-email-amwang@redhat.com>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934436Ab1ETJGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 05:06:49 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p4K96n3Z013048
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 05:06:49 -0400
In-Reply-To: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two events are not expected to be caught by userspace.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 net/core/rtnetlink.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2ba259..d1644e3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1956,6 +1956,8 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_GOING_DOWN:
 	case NETDEV_UNREGISTER:
 	case NETDEV_UNREGISTER_BATCH:
+	case NETDEV_RELEASE:
+	case NETDEV_JOIN:
 		break;
 	default:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
-- 
1.7.1

