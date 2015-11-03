From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 3 Nov 2015 11:17:23 +1100
Message-ID: <20151103111723.010c7ede@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ani Sinha <ani@arista.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/ipmr.c

between commit:

  44f49dd8b5a6 ("ipmr: fix possible race resulting from improper usage of IP_INC_STATS_BH() in preemptible context.")

from the net tree and commit:

  758ccac8e741 ("ipv4: Only compute net once in ipmr_forward_finish")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ipmr.c
index 8e8203d5c520,fc42525d8694..000000000000
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@@ -1682,8 -1683,8 +1683,8 @@@ static inline int ipmr_forward_finish(s
  {
  	struct ip_options *opt = &(IPCB(skb)->opt);
  
- 	IP_INC_STATS(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
- 	IP_ADD_STATS(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 -	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
 -	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
++	IP_INC_STATS(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
++	IP_ADD_STATS(net, IPSTATS_MIB_OUTOCTETS, skb->len);
  
  	if (unlikely(opt->optlen))
  		ip_forward_options(skb);
@@@ -1745,7 -1746,7 +1746,7 @@@ static void ipmr_queue_xmit(struct net 
  		 * to blackhole.
  		 */
  
- 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 -		IP_INC_STATS_BH(net, IPSTATS_MIB_FRAGFAILS);
++		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
  		ip_rt_put(rt);
  		goto out_free;
  	}
