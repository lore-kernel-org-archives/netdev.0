From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 23 Sep 2010 12:14:13 +1000
Message-ID: <20100923121413.d48e2b1b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/ip_output.c between commit
3d13008e7345fa7a79d8f6438150dc15d6ba6e9d ("ip: fix truesize mismatch in
ip fragmentation") from the net-current tree and commit
21dc330157454046dd7c494961277d76e1c957fe ("net: Rename skb_has_frags to
skb_has_frag_list") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix
for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ip_output.c
index 7649d77,e427620..0000000
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@@ -487,9 -487,10 +487,9 @@@ int ip_fragment(struct sk_buff *skb, in
  	 * LATER: this step can be merged to real generation of fragments,
  	 * we can switch to copy when see the first bad fragment.
  	 */
- 	if (skb_has_frags(skb)) {
+ 	if (skb_has_frag_list(skb)) {
 -		struct sk_buff *frag;
 +		struct sk_buff *frag, *frag2;
  		int first_len = skb_pagelen(skb);
 -		int truesizes = 0;
  
  		if (first_len - hlen > mtu ||
  		    ((first_len - hlen) & 7) ||
