From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 12/14] user_ns: target af_key capability check
Date: Tue, 26 Jul 2011 18:58:35 +0000
Message-ID: <1311706717-7398-13-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

This presumes that it really is complete wrt network namespaces.  Looking
at the code it appears to be.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/key/af_key.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1e733e9..1f90f4e 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -141,7 +141,7 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
-- 
1.7.4.1
