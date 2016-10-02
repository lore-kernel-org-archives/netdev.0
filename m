From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 3 Oct 2016 09:37:08 +1100
Message-ID: <20161003093708.6cecf656@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Xin Long <lucien.xin@gmail.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sctp/sctp_diag.c

between commit:

  1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")

from Linus' tree and commit:

  d545caca827b ("net: inet: diag: expose the socket mark to privileged processes.")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sctp/sctp_diag.c
index cef0cee182d4,807158e32f5f..000000000000
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@@ -299,9 -314,10 +303,10 @@@ static int sctp_sock_dump(struct sock *
  					sk_user_ns(NETLINK_CB(cb->skb).sk),
  					NETLINK_CB(cb->skb).portid,
  					cb->nlh->nlmsg_seq,
- 					NLM_F_MULTI, cb->nlh) < 0) {
+ 					NLM_F_MULTI, cb->nlh,
+ 					commp->net_admin) < 0) {
  			cb->args[3] = 1;
 -			err = 2;
 +			err = 1;
  			goto release;
  		}
  		cb->args[3] = 1;
@@@ -309,8 -325,9 +314,9 @@@
  		if (inet_sctp_diag_fill(sk, assoc, skb, r,
  					sk_user_ns(NETLINK_CB(cb->skb).sk),
  					NETLINK_CB(cb->skb).portid,
- 					cb->nlh->nlmsg_seq, 0, cb->nlh) < 0) {
+ 					cb->nlh->nlmsg_seq, 0, cb->nlh,
+ 					commp->net_admin) < 0) {
 -			err = 2;
 +			err = 1;
  			goto release;
  		}
  next:
