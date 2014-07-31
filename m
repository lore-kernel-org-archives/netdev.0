From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] team: fix releasing uninitialized pointer to BPF prog
Date: Thu, 31 Jul 2014 21:48:59 +0200
Message-ID: <1406836139-11943-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Pablo Neira <pablo@netfilter.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@resnulli.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796AbaGaTtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:49:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 34c5bd66e5ed introduced the possibility that an
uninitialized pointer on the stack (orig_fp) can call into
sk_unattached_filter_destroy() when its value is non NULL.

Before that commit orig_fp was only destroyed in the same
block where it was assigned a valid BPF prog before. Fix it
up by initializing it to NULL.

Fixes: 34c5bd66e5ed ("net: filter: don't release unattached filter through call_rcu()")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Pablo Neira <pablo@netfilter.org>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team_mode_loadbalance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 7106f34..d7be9b3 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -272,7 +272,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
 	struct sk_filter *fp = NULL;
-	struct sk_filter *orig_fp;
+	struct sk_filter *orig_fp = NULL;
 	struct sock_fprog_kern *fprog = NULL;
 	int err;
 
-- 
1.9.0
