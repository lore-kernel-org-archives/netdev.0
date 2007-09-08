From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 17/16] net: Disable netfilter sockopts when not in the initial network namespace
Date: Sat, 08 Sep 2007 15:47:12 -0600
Message-ID: <m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
	<m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com>
	<m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40191 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbXIHVsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:48:01 -0400
In-Reply-To: <m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 08 Sep 2007 15:43:44 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Until we support multiple network namespaces with netfilter only allow
netfilter configuration in the initial network namespace.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

Ooops I overlooked this one on my first path through when gathering up this
patchset.

 net/netfilter/nf_sockopt.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index 8b8ece7..c12ea9b 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -80,6 +80,9 @@ static int nf_sockopt(struct sock *sk, int pf, int val,
 	struct nf_sockopt_ops *ops;
 	int ret;
 
+	if (sk->sk_net != &init_net)
+		return -ENOPROTOOPT;
+
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
 		return -EINTR;
 
@@ -138,6 +141,10 @@ static int compat_nf_sockopt(struct sock *sk, int pf, int val,
 	struct nf_sockopt_ops *ops;
 	int ret;
 
+	if (sk->sk_net != &init_net)
+		return -ENOPROTOOPT;
+
+
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
 		return -EINTR;
 
-- 
1.5.3.rc6.17.g1911

