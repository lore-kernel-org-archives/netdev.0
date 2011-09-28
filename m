From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Wed, 28 Sep 2011 12:54:28 +1000
Message-ID: <20110928125428.70d5cf10ea59f729135d5dff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/batman-adv/soft-interface.c between commit 8b267b312df9 ("batman-adv:
do_bcast has to be true for broadcast packets only") from the net-current
tree and commit 3d393e473210 ("batman-adv: implement AP-isolation on the
sender side") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/soft-interface.c
index 05dd351,aceeabc..0000000
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@@ -595,11 -596,12 +596,12 @@@ static int interface_tx(struct sk_buff 
  		goto dropped;
  
  	/* Register the client MAC in the transtable */
- 	tt_local_add(soft_iface, ethhdr->h_source);
+ 	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
  
- 	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+ 	orig_node = transtable_search(bat_priv, ethhdr->h_source,
+ 				      ethhdr->h_dest);
 -	if (is_multicast_ether_addr(ethhdr->h_dest) ||
 -				(orig_node && orig_node->gw_flags)) {
 +	do_bcast = is_multicast_ether_addr(ethhdr->h_dest);
 +	if (do_bcast ||	(orig_node && orig_node->gw_flags)) {
  		ret = gw_is_target(bat_priv, skb, orig_node);
  
  		if (ret < 0)
