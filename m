From: Jan Engelhardt <jengelh@medozas.de>
Subject: [patch] netlink: use TID instead of PID for automatic id
 assignment
Date: Sun, 31 Oct 2010 20:14:00 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1010312013100.20872@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55176 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab0JaTOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 15:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent 3985c7ce85039adacdf882904ca096f091d39346 (v2.6.36-9871-g3985c7c)
commit 183ded547d51508f23f6c18a999f6c165e66c99e
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Oct 31 20:09:36 2010 +0100

netlink: use TID instead of PID for automatic id assignment

This makes it easier to identify processes in the output of `ss -af
netlink` - as I see no reason to force negative space numbers upon
all but the first socket in a thread group.

Turns out this reverts v2.6.15-rc4~65.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 478181d..568d07c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -545,7 +545,7 @@ static int netlink_autobind(struct socket *sock)
 	struct hlist_head *head;
 	struct sock *osk;
 	struct hlist_node *node;
-	s32 pid = task_tgid_vnr(current);
+	s32 pid = task_pid_vnr(current);
 	int err;
 	static s32 rover = -4097;
 
-- 
# Created with git-export-patch

