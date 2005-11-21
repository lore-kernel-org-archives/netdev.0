From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK]: Use tgid instead of pid for nlmsg_pid
Date: Tue, 22 Nov 2005 09:16:27 +1100
Message-ID: <E1EeJxb-0006xG-00@gondolin.me.apana.org.au>
References: <20051121213549.GA28187@ms2.inr.ac.ru>
Cc: herbert@gondor.apana.org.au, cfriesen@nortel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751152AbVKUWQi@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
In-Reply-To: <20051121213549.GA28187@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> I agree, apparently netlink_autobind was missed when sed'ing pid->tgid.
> Of course, it does not matter, but tgid is nicer choice from user's viewpoint.

Great, here is the patch to do just that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -476,7 +476,7 @@ static int netlink_autobind(struct socke
 	struct hlist_head *head;
 	struct sock *osk;
 	struct hlist_node *node;
-	s32 pid = current->pid;
+	s32 pid = current->tgid;
 	int err;
 	static s32 rover = -4097;
 
