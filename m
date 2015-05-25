From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 741/754] net/ipv6/ip6_output.c:587:17: sparse:
 incorrect type in assignment (different base types)
Date: Tue, 26 May 2015 05:35:46 +0800
Message-ID: <201505260544.3guHqjoi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12681 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbbEYVgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 17:36:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   376cd36dc7b68ec7f7de1428fa055ce706a33bbf
commit: 286c2349f6665c3e67f464a5faa14a0e28be4842 [741/754] ipv6: Clean up ipv6_select_ident() and ip6_fragment()
reproduce:
  # apt-get install sparse
  git checkout 286c2349f6665c3e67f464a5faa14a0e28be4842
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv6/ip6_output.c:587:17: sparse: incorrect type in assignment (different base types)
   net/ipv6/ip6_output.c:587:17:    expected restricted __be32 [usertype] frag_id
   net/ipv6/ip6_output.c:587:17:    got unsigned int
>> net/ipv6/ip6_output.c:1105:38: sparse: incorrect type in assignment (different base types)
   net/ipv6/ip6_output.c:1105:38:    expected restricted __be32 [usertype] ip6_frag_id
   net/ipv6/ip6_output.c:1105:38:    got unsigned int
--
>> net/ipv6/output_core.c:72:16: sparse: incorrect type in return expression (different base types)
   net/ipv6/output_core.c:72:16:    expected unsigned int
   net/ipv6/output_core.c:72:16:    got restricted __be32 [usertype] <noident>

vim +587 net/ipv6/ip6_output.c

   571				sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
   572	
   573			skb->dev = skb_dst(skb)->dev;
   574			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
   575			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
   576				      IPSTATS_MIB_FRAGFAILS);
   577			kfree_skb(skb);
   578			return -EMSGSIZE;
   579		}
   580	
   581		if (np && np->frag_size < mtu) {
   582			if (np->frag_size)
   583				mtu = np->frag_size;
   584		}
   585		mtu -= hlen + sizeof(struct frag_hdr);
   586	
 > 587		frag_id = ipv6_select_ident(net, rt);
   588	
   589		if (skb_has_frag_list(skb)) {
   590			int first_len = skb_pagelen(skb);
   591			struct sk_buff *frag2;
   592	
   593			if (first_len - hlen > mtu ||
   594			    ((first_len - hlen) & 7) ||
   595			    skb_cloned(skb))

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
