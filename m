From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 187/208] net/mpls/mpls_iptunnel.c:73:19: sparse:
 incompatible types in comparison expression (different address spaces)
Date: Wed, 22 Jul 2015 08:53:58 +0800
Message-ID: <201507220856.Z54YIUoH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4958 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934008AbbGVAyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 20:54:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   16040894b26af9f85d9395f072c53d76a44eba21
commit: e3e4712ec0961ed586a8db340bd994c4ad7f5dba [187/208] mpls: ip tunnel support
reproduce:
  # apt-get install sparse
  git checkout e3e4712ec0961ed586a8db340bd994c4ad7f5dba
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/mpls/mpls_iptunnel.c:73:19: sparse: incompatible types in comparison expression (different address spaces)

vim +73 net/mpls/mpls_iptunnel.c

    57		/* Obtain the ttl */
    58		if (skb->protocol == htons(ETH_P_IP)) {
    59			ttl = ip_hdr(skb)->ttl;
    60			rt = (struct rtable *)dst;
    61			lwtstate = rt->rt_lwtstate;
    62		} else if (skb->protocol == htons(ETH_P_IPV6)) {
    63			ttl = ipv6_hdr(skb)->hop_limit;
    64			rt6 = (struct rt6_info *)dst;
    65			lwtstate = rt6->rt6i_lwtstate;
    66		} else {
    67			goto drop;
    68		}
    69	
    70		skb_orphan(skb);
    71	
    72		/* Find the output device */
  > 73		out_dev = rcu_dereference(dst->dev);
    74		if (!mpls_output_possible(out_dev) ||
    75		    !lwtstate || skb_warn_if_lro(skb))
    76			goto drop;
    77	
    78		skb_forward_csum(skb);
    79	
    80		tun_encap_info = mpls_lwtunnel_encap(lwtstate);
    81	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
