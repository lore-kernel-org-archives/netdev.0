From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 12 May 2016 09:56:21 +1000
Message-ID: <20160512095621.61519433@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/ip_gre.c

between commit:

  e271c7b4420d ("gre: do not keep the GRE header around in collect medata mode")

from the net tree and commit:

  244a797bdcf1 ("gre: move iptunnel_pull_header down to ipgre_rcv")

from the net-next tree.

I fixed it up (hopefully - see below) and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/ipv4/ip_gre.c
index 4cc84212cce1,2b267e71ebf5..4d1030739efa
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@@ -398,10 -272,11 +272,14 @@@ static int __ipgre_rcv(struct sk_buff *
  				  iph->saddr, iph->daddr, tpi->key);
  
  	if (tunnel) {
+ 		if (__iptunnel_pull_header(skb, hdr_len, tpi->proto,
+ 					   raw_proto, false) < 0)
+ 			goto drop;
+ 
 -		skb_pop_mac_header(skb);
 +		if (tunnel->dev->type != ARPHRD_NONE)
 +			skb_pop_mac_header(skb);
 +		else
 +			skb_reset_mac_header(skb);
  		if (tunnel->collect_md) {
  			__be16 flags;
  			__be64 tun_id;
