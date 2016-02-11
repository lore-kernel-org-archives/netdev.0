From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 11 Feb 2016 11:59:41 +1100
Message-ID: <20160211115941.701f67b2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Wragg <david@weave.works>, Jiri Benc <jbenc@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/vxlan.c

between commit:

  72564b59ffc4 ("vxlan: Relax MTU constraints")

from the net tree and commit:

  1a8496ba4091 ("vxlan: consolidate output route calculation")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/vxlan.c
index a31cd954b308,65f52472a52c..000000000000
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@@ -2395,40 -2316,6 +2321,15 @@@ static int __vxlan_change_mtu(struct ne
  	return 0;
  }
  
 +static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 +{
 +	struct vxlan_dev *vxlan = netdev_priv(dev);
 +	struct vxlan_rdst *dst = &vxlan->default_dst;
 +	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
 +							 dst->remote_ifindex);
 +	return __vxlan_change_mtu(dev, lowerdev, dst, new_mtu, true);
 +}
 +
- static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
- 				struct ip_tunnel_info *info,
- 				__be16 sport, __be16 dport)
- {
- 	struct vxlan_dev *vxlan = netdev_priv(dev);
- 	struct rtable *rt;
- 	struct flowi4 fl4;
- 
- 	memset(&fl4, 0, sizeof(fl4));
- 	fl4.flowi4_tos = RT_TOS(info->key.tos);
- 	fl4.flowi4_mark = skb->mark;
- 	fl4.flowi4_proto = IPPROTO_UDP;
- 	fl4.daddr = info->key.u.ipv4.dst;
- 
- 	rt = ip_route_output_key(vxlan->net, &fl4);
- 	if (IS_ERR(rt))
- 		return PTR_ERR(rt);
- 	ip_rt_put(rt);
- 
- 	info->key.u.ipv4.src = fl4.saddr;
- 	info->key.tp_src = sport;
- 	info->key.tp_dst = dport;
- 	return 0;
- }
- 
  static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
  {
  	struct vxlan_dev *vxlan = netdev_priv(dev);
