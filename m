From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 15 Dec 2015 11:31:29 +1100
Message-ID: <20151215113129.197e5e0b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/geneve.c

between commit:

  a322a1bcf329 ("geneve: Fix IPv6 xmit stats update.")

from the net tree and commit:

  abe492b4f50c ("geneve: UDP checksum configuration via netlink")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/geneve.c
index c2b79f5d1c89,0750d7a93878..000000000000
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@@ -966,7 -984,10 +984,8 @@@ static netdev_tx_t geneve6_xmit_skb(str
  	}
  	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
  				   &fl6.saddr, &fl6.daddr, prio, ttl,
- 				   sport, geneve->dst_port, !udp_csum);
+ 				   sport, geneve->dst_port,
+ 				   !!(flags & GENEVE_F_UDP_ZERO_CSUM6_TX));
 -
 -	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
  	return NETDEV_TX_OK;
  
  tx_error:
