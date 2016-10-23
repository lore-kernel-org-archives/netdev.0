From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 24 Oct 2016 10:34:16 +1100
Message-ID: <20161024103416.02bef8bb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  include/net/udp.h

between commit:

  286c72deabaa ("udp: must lock the socket in udp_disconnect()")

from the net tree and commit:

  f970bd9e3a06 ("udp: implement memory accounting helpers")

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

diff --cc include/net/udp.h
index 4948790d393d,18f1e6b91927..000000000000
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@@ -258,7 -261,7 +261,8 @@@ void udp_flush_pending_frames(struct so
  void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
  int udp_rcv(struct sk_buff *skb);
  int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+ int udp_init_sock(struct sock *sk);
 +int __udp_disconnect(struct sock *sk, int flags);
  int udp_disconnect(struct sock *sk, int flags);
  unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
  struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
