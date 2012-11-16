From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 63/70] net/ipv6/udp_offload.c:29:2: error:
 implicit declaration of function 'csum_ipv6_magic'
Date: Fri, 16 Nov 2012 08:12:05 +0800
Message-ID: <50a584d5.9dutnkC1pLuFHpWQ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11255 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868Ab2KPAMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 19:12:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   7213dde6c961230d1e4c80fa20df842af573cd9d
commit: 5edbb07dc9474b7d4cd4391a2e6551ad067a0f96 [63/70] ipv6: Separate out UDP offload functionality
config: make ARCH=powerpc chroma_defconfig

All error/warnings:

net/ipv6/udp_offload.c: In function 'udp6_ufo_send_check':
net/ipv6/udp_offload.c:29:2: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

vim +29 +/csum_ipv6_magic net/ipv6/udp_offload.c

5edbb07d Vlad Yasevich 2012-11-15  23  	if (!pskb_may_pull(skb, sizeof(*uh)))
5edbb07d Vlad Yasevich 2012-11-15  24  		return -EINVAL;
5edbb07d Vlad Yasevich 2012-11-15  25  
5edbb07d Vlad Yasevich 2012-11-15  26  	ipv6h = ipv6_hdr(skb);
5edbb07d Vlad Yasevich 2012-11-15  27  	uh = udp_hdr(skb);
5edbb07d Vlad Yasevich 2012-11-15  28  
5edbb07d Vlad Yasevich 2012-11-15 @29  	uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
5edbb07d Vlad Yasevich 2012-11-15  30  				     IPPROTO_UDP, 0);
5edbb07d Vlad Yasevich 2012-11-15  31  	skb->csum_start = skb_transport_header(skb) - skb->head;
5edbb07d Vlad Yasevich 2012-11-15  32  	skb->csum_offset = offsetof(struct udphdr, check);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
