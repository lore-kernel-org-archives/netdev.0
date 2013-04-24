From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] netfilter: nf_nat: missing condition in
 nf_xfrm_me_harder()
Date: Wed, 24 Apr 2013 18:11:51 +0300
Message-ID: <20130424151151.GA16783@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This if statement was accidentally dropped in a merge commit so now it
returns unconditionally.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 2e469ca..d4c9a31 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -90,6 +90,7 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 	int err;
 
 	err = xfrm_decode_session(skb, &fl, family);
+	if (err)
 		return err;
 
 	dst = skb_dst(skb);
