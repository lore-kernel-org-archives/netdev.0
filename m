From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the ipsec tree
Date: Tue, 6 Oct 2015 11:24:55 +1100
Message-ID: <20151006112455.584daaf0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv6/xfrm6_output.c

between commit:

  93efac3f2e03 ("ipv6: Fix IPsec pre-encap fragmentation check")

from the ipsec tree and commit:

  7d8c6e391575 ("ipv6: Pass struct net through ip6_fragment")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/xfrm6_output.c
index be033f22a3f3,4cefda009f53..000000000000
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@@ -163,11 -164,12 +170,11 @@@ static int __xfrm6_output(struct net *n
  		return -EMSGSIZE;
  	}
  
 -	if (x->props.mode == XFRM_MODE_TUNNEL &&
 -	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 -		dst_allfrag(skb_dst(skb)))) {
 +	if (toobig || dst_allfrag(skb_dst(skb)))
- 		return ip6_fragment(sk, skb,
- 				    x->outer_mode->afinfo->output_finish);
+ 		return ip6_fragment(net, sk, skb,
+ 				    __xfrm6_output_finish);
 -	}
 +
 +skip_frag:
  	return x->outer_mode->afinfo->output_finish(sk, skb);
  }
  
