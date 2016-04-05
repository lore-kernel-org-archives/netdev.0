From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 58/68] net/ipv4/udp.c:1693:9: sparse: incompatible
 types in comparison expression (different address spaces)
Date: Tue, 5 Apr 2016 12:38:34 +0800
Message-ID: <201604051231.l9wUsxHm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:47002 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbcDEEj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 00:39:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   15f41e2ba13a6726632e44b1180e805a61e470ad
commit: ca065d0cf80fa547724440a8bf37f1e674d917c0 [58/68] udp: no longer use SLAB_DESTROY_BY_RCU
reproduce:
        # apt-get install sparse
        git checkout ca065d0cf80fa547724440a8bf37f1e674d917c0
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:232:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/ipv4/udp.c:1693:9: sparse: incompatible types in comparison expression (different address spaces)
>> net/ipv4/udp.c:1693:9: sparse: incompatible types in comparison expression (different address spaces)
--
   include/linux/compiler.h:232:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/ipv6/udp.c:743:9: sparse: incompatible types in comparison expression (different address spaces)
>> net/ipv6/udp.c:743:9: sparse: incompatible types in comparison expression (different address spaces)

vim +1693 net/ipv4/udp.c

  1677		struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
  1678		unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
  1679		unsigned int offset = offsetof(typeof(*sk), sk_node);
  1680		int dif = skb->dev->ifindex;
  1681		struct hlist_node *node;
  1682		struct sk_buff *nskb;
  1683	
  1684		if (use_hash2) {
  1685			hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
  1686				    udp_table.mask;
  1687			hash2 = udp4_portaddr_hash(net, daddr, hnum) & udp_table.mask;
  1688	start_lookup:
  1689			hslot = &udp_table.hash2[hash2];
  1690			offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
  1691		}
  1692	
> 1693		sk_for_each_entry_offset_rcu(sk, node, &hslot->head, offset) {
  1694			if (!__udp_is_mcast_sock(net, sk, uh->dest, daddr,
  1695						 uh->source, saddr, dif, hnum))
  1696				continue;
  1697	
  1698			if (!first) {
  1699				first = sk;
  1700				continue;
  1701			}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
