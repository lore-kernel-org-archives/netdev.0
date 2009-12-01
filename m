From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: [PATCH 1/1] net: compat_sys_recvmmsg user timespec arg can be NULL
Date: Tue,  1 Dec 2009 15:52:16 -0200
Message-ID: <1259689936-27570-1-git-send-email-acme@infradead.org>
Cc: netdev@vger.kernel.org,
	Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38058 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515AbZLARwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 12:52:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>

We must test if user timespec is non-NULL before copying from userpace,
same as sys_recvmmsg().

Commiter note: changed it so that we have just one branch.

Signed-off-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/compat.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 6a2f75f..e1a56ad 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -758,9 +758,13 @@ asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
 {
 	int datagrams;
 	struct timespec ktspec;
-	struct compat_timespec __user *utspec =
-			(struct compat_timespec __user *)timeout;
+	struct compat_timespec __user *utspec;
 
+	if (timeout == NULL)
+		return __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+				      flags | MSG_CMSG_COMPAT, NULL);
+
+	utspec = (struct compat_timespec __user *)timeout;
 	if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
 	    get_user(ktspec.tv_nsec, &utspec->tv_nsec))
 		return -EFAULT;
-- 
1.6.2.5

