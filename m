From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 14 Jun 2017 10:25:30 +1000
Message-ID: <20170614102530.2db9f65c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andreas Pape <apape@phoenixcontact.com>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Sven Eckelmann <sven@narfation.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/batman-adv/routing.c

between commit:

  a1a745ef980a ("batman-adv: fix memory leak when dropping packet from other gateway")

from the net tree and commit:

  22f0502ed9f3 ("batman-adv: Print correct function names in dbg messages")

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

diff --cc net/batman-adv/routing.c
index ae9f4d37d34f,1338b9221613..000000000000
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@@ -985,9 -985,9 +985,9 @@@ int batadv_recv_unicast_packet(struct s
  			batadv_orig_node_put(orig_node_gw);
  			if (is_gw) {
  				batadv_dbg(BATADV_DBG_BLA, bat_priv,
- 					   "recv_unicast_packet(): Dropped unicast pkt received from another backbone gw %pM.\n",
- 					   orig_addr_gw);
+ 					   "%s(): Dropped unicast pkt received from another backbone gw %pM.\n",
+ 					   __func__, orig_addr_gw);
 -				return NET_RX_DROP;
 +				goto free_skb;
  			}
  		}
  
