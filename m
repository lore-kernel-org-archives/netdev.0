From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 35/50] net/ipv6/sit.c:1232:52: sparse: incorrect type in argument 3 (different base types)
Date: Thu, 15 Nov 2012 13:31:07 +0800
Message-ID: <50a47e1b.44+0DGGKGr4JHNPK%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19376 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab2KOFbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 00:31:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   702ed3c1a9dfe4dfe112f13542d0c9d689f5008b
commit: a12c9a85813e927e1143989876d70697eb85aac9 [35/50] sit/rtnl: add missing parameters on dump


sparse warnings:

net/ipv6/sit.c:263:18: sparse: restricted __be16 degrades to integer
+ net/ipv6/sit.c:1232:52: sparse: incorrect type in argument 3 (different base types)
net/ipv6/sit.c:1232:52:    expected unsigned short [unsigned] [usertype] value
net/ipv6/sit.c:1232:52:    got restricted __be16 [usertype] i_flags

vim +1232 net/ipv6/sit.c

a12c9a85 Nicolas Dichtel 2012-11-14  1216  		nla_total_size(2) +
ba3e3f50 Nicolas Dichtel 2012-11-09  1217  		0;
ba3e3f50 Nicolas Dichtel 2012-11-09  1218  }
ba3e3f50 Nicolas Dichtel 2012-11-09  1219  
ba3e3f50 Nicolas Dichtel 2012-11-09  1220  static int sit_fill_info(struct sk_buff *skb, const struct net_device *dev)
ba3e3f50 Nicolas Dichtel 2012-11-09  1221  {
ba3e3f50 Nicolas Dichtel 2012-11-09  1222  	struct ip_tunnel *tunnel = netdev_priv(dev);
ba3e3f50 Nicolas Dichtel 2012-11-09  1223  	struct ip_tunnel_parm *parm = &tunnel->parms;
ba3e3f50 Nicolas Dichtel 2012-11-09  1224  
ba3e3f50 Nicolas Dichtel 2012-11-09  1225  	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
ba3e3f50 Nicolas Dichtel 2012-11-09  1226  	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
ba3e3f50 Nicolas Dichtel 2012-11-09  1227  	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
ba3e3f50 Nicolas Dichtel 2012-11-09  1228  	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
a12c9a85 Nicolas Dichtel 2012-11-14  1229  	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
a12c9a85 Nicolas Dichtel 2012-11-14  1230  	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
a12c9a85 Nicolas Dichtel 2012-11-14  1231  		       !!(parm->iph.frag_off & htons(IP_DF))) ||
a12c9a85 Nicolas Dichtel 2012-11-14 @1232  	    nla_put_u16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
ba3e3f50 Nicolas Dichtel 2012-11-09  1233  		goto nla_put_failure;
ba3e3f50 Nicolas Dichtel 2012-11-09  1234  	return 0;
ba3e3f50 Nicolas Dichtel 2012-11-09  1235  
ba3e3f50 Nicolas Dichtel 2012-11-09  1236  nla_put_failure:
ba3e3f50 Nicolas Dichtel 2012-11-09  1237  	return -EMSGSIZE;
ba3e3f50 Nicolas Dichtel 2012-11-09  1238  }
ba3e3f50 Nicolas Dichtel 2012-11-09  1239  
ba3e3f50 Nicolas Dichtel 2012-11-09  1240  static struct rtnl_link_ops sit_link_ops __read_mostly = {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
