From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 790/1189] net/ipv6/netfilter/nf_dup_ipv6.c:48:23:
 sparse: incorrect type in assignment (different base types)
Date: Fri, 21 Aug 2015 14:20:05 +0800
Message-ID: <201508211403.fcba7yhA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42016 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbbHUGS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 02:18:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   a9e01ed986aa80d3092134428f453072752da223
commit: bbde9fc1824aab58bc78c084163007dd6c03fe5b [790/1189] netfilter: factor out packet duplication for IPv4/IPv6
reproduce:
  # apt-get install sparse
  git checkout bbde9fc1824aab58bc78c084163007dd6c03fe5b
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv6/netfilter/nf_dup_ipv6.c:48:23: sparse: incorrect type in assignment (different base types)
   net/ipv6/netfilter/nf_dup_ipv6.c:48:23:    expected restricted __be32 [addressable] [assigned] [usertype] flowlabel
   net/ipv6/netfilter/nf_dup_ipv6.c:48:23:    got int

vim +48 net/ipv6/netfilter/nf_dup_ipv6.c

    32		return &init_net;
    33	}
    34	
    35	static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_addr *gw,
    36				      int oif)
    37	{
    38		const struct ipv6hdr *iph = ipv6_hdr(skb);
    39		struct net *net = pick_net(skb);
    40		struct dst_entry *dst;
    41		struct flowi6 fl6;
    42	
    43		memset(&fl6, 0, sizeof(fl6));
    44		if (oif != -1)
    45			fl6.flowi6_oif = oif;
    46	
    47		fl6.daddr = *gw;
  > 48		fl6.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
    49				 (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
    50		dst = ip6_route_output(net, NULL, &fl6);
    51		if (dst->error) {
    52			dst_release(dst);
    53			return false;
    54		}
    55		skb_dst_drop(skb);
    56		skb_dst_set(skb, dst);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
