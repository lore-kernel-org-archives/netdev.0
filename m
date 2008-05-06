From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 18/18] flag parameters: check magic constants
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933166AbYEFVSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds test that ensure the boundary conditions for the various
constants introduced in the previous patches is met.  No code is generated.

 fs/eventfd.c      |    4 ++++
 fs/eventpoll.c    |    3 +++
 fs/inotify_user.c |    4 ++++
 fs/signalfd.c     |    4 ++++
 fs/timerfd.c      |    4 ++++
 net/socket.c      |    7 +++++++
 6 files changed, 26 insertions(+)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 3ed4466..08bf558 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -203,6 +203,10 @@ asmlinkage long sys_eventfd2(unsigned int count, int flags)
 	int fd;
 	struct eventfd_ctx *ctx;
 
+	/* Check the EFD_* constants for consistency.  */
+	BUILD_BUG_ON(EFD_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(EFD_NONBLOCK != O_NONBLOCK);
+
 	if (flags & ~(EFD_CLOEXEC | EFD_NONBLOCK))
 		return -EINVAL;
 
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 3fd4014..2fdad42 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1051,6 +1051,9 @@ asmlinkage long sys_epoll_create2(int size, int flags)
 	int error, fd = -1;
 	struct eventpoll *ep;
 
+	/* Check the EPOLL_* constant for consistency.  */
+	BUILD_BUG_ON(EPOLL_CLOEXEC != O_CLOEXEC);
+
 	if (flags & ~EPOLL_CLOEXEC)
 		return -EINVAL;
 
diff --git a/fs/inotify_user.c b/fs/inotify_user.c
index dc7e1f6..fe79c25 100644
--- a/fs/inotify_user.c
+++ b/fs/inotify_user.c
@@ -574,6 +574,10 @@ asmlinkage long sys_inotify_init1(int flags)
 	struct file *filp;
 	int fd, ret;
 
+	/* Check the IN_* constants for consistency.  */
+	BUILD_BUG_ON(IN_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(IN_NONBLOCK != O_NONBLOCK);
+
 	if (flags & ~(IN_CLOEXEC | IN_NONBLOCK))
 		return -EINVAL;
 
diff --git a/fs/signalfd.c b/fs/signalfd.c
index 5441a4b..9c39bc7 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -211,6 +211,10 @@ asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask,
 	sigset_t sigmask;
 	struct signalfd_ctx *ctx;
 
+	/* Check the SFD_* constants for consistency.  */
+	BUILD_BUG_ON(SFD_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(SFD_NONBLOCK != O_NONBLOCK);
+
 	if (flags & ~(SFD_CLOEXEC | SFD_NONBLOCK))
 		return -EINVAL;
 
diff --git a/fs/timerfd.c b/fs/timerfd.c
index 75d44ef..c502c60 100644
--- a/fs/timerfd.c
+++ b/fs/timerfd.c
@@ -184,6 +184,10 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
 	int ufd;
 	struct timerfd_ctx *ctx;
 
+	/* Check the TFD_* constants for consistency.  */
+	BUILD_BUG_ON(TFD_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(TFD_NONBLOCK != O_NONBLOCK);
+
 	if (flags & ~(TFD_CLOEXEC | TFD_NONBLOCK))
 		return -EINVAL;
 	if (clockid != CLOCK_MONOTONIC &&
diff --git a/net/socket.c b/net/socket.c
index 7cb0a5e..962bf07 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1219,6 +1219,13 @@ asmlinkage long sys_socket(int family, int type, int protocol)
 	struct socket *sock;
 	int flags;
 
+	/* Check the SOCK_* constants for consistency.  */
+	BUILD_BUG_ON(SOCK_CLOEXEC != O_CLOEXEC);
+	BUILD_BUG_ON(SOCK_NONBLOCK != O_NONBLOCK);
+	BUILD_BUG_ON((SOCK_MAX | SOCK_TYPE_MASK) != SOCK_TYPE_MASK);
+	BUILD_BUG_ON(SOCK_CLOEXEC & SOCK_TYPE_MASK);
+	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
+
 	flags = type & ~SOCK_TYPE_MASK;
 	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
 		return -EINVAL;
