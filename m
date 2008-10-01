From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed,  1 Oct 2008 14:54:14 +0400
Message-ID: <1222858454-7843-1-git-send-email-den@openvz.org>
Cc: xemul@openvz.org, netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, ebiederm@xmission.com, den@openvz.org
To: containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:8161 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbYJAKzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 06:55:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch opens a way to connect via Unix socket from one namespace
to another if these sockets are opened via conventional filesystem
interface. Such approach allows to share important services between
namespaces in efficient way.

This breach is controlled by the means of shared filesystem, i.e. if
somebody really wants to isolate containers, he should start from
filesystem separation.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/unix/af_unix.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 39d2173..0e1eccd 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -297,9 +297,6 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
 		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
 		struct dentry *dentry = unix_sk(s)->dentry;
 
-		if (!net_eq(sock_net(s), net))
-			continue;
-
 		if(dentry && dentry->d_inode == i)
 		{
 			sock_hold(s);
-- 
1.5.3.rc5

