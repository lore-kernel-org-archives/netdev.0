From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] scm: Only support SCM_RIGHTS on unix domain sockets.
Date: Sun, 28 Feb 2010 03:20:36 -0800
Message-ID: <m1eik5d2t7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34837 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031801Ab0B1LUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 06:20:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We use scm_send and scm_recv on both unix domain and
netlink sockets, but only unix domain sockets support
everything required for file descriptor passing,
so error if someone attempts to pass file descriptors
over netlink sockets.

Cc: stable@kernel.org
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/scm.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index b7ba91b..9b26463 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -156,6 +156,8 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 		switch (cmsg->cmsg_type)
 		{
 		case SCM_RIGHTS:
+			if (!sock->ops || sock->ops->family != PF_UNIX)
+				goto error;
 			err=scm_fp_copy(cmsg, &p->fp);
 			if (err<0)
 				goto error;
-- 
1.6.5.2.143.g8cc62

