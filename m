From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 3 May 2016 13:15:24 +1000
Message-ID: <20160503131524.5341da81@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>, Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/ip_gre.c

between commits:

  2090714e1d6e ("gre: build header correctly for collect metadata tunnels")
  b7f8fe251e46 ("gre: do not pull header in ICMP error processing")

from Linus' tree and commit:

  95f5c64c3c13 ("gre: Move utility functions to common headers")
  182a352d2d5e ("gre: Create common functions for transmit")

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

diff --cc net/ipv4/ip_gre.c
index 205a2b8a5a84,2480d79b0e37..000000000000
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@@ -341,8 -221,9 +221,9 @@@ static void gre_err(struct sk_buff *skb
  	const int code = icmp_hdr(skb)->code;
  	struct tnl_ptk_info tpi;
  	bool csum_err = false;
+ 	int hdr_len;
  
- 	if (parse_gre_header(skb, &tpi, &csum_err) < 0) {
 -	if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len)) {
++	if (gre_parse_header(skb, &tpi, &csum_err, &hdr_len) < 0) {
  		if (!csum_err)		/* ignore csum errors. */
  			return;
  	}
@@@ -574,15 -414,12 +415,12 @@@ static void gre_fb_xmit(struct sk_buff 
  	}
  
  	/* Push Tunnel header. */
- 	skb = gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM));
- 	if (IS_ERR(skb)) {
- 		skb = NULL;
+ 	if (gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM)))
  		goto err_free_rt;
- 	}
  
  	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
- 	build_header(skb, tunnel_hlen, flags, proto,
- 		     tunnel_id_to_key(tun_info->key.tun_id), 0);
 -	gre_build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
++	gre_build_header(skb, tunnel_hlen, flags, proto,
+ 			 tunnel_id_to_key(tun_info->key.tun_id), 0);
  
  	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
  
