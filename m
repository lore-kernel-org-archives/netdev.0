From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [net:master 9/12] net/ipv6/ip6_offload.c:120:7-21: WARNING: Unsigned
 expression compared with zero: unfrag_ip6hlen < 0 (fwd)
Date: Thu, 18 May 2017 10:01:07 +0800 (SGT)
Message-ID: <alpine.DEB.2.20.1705181000150.3833@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, kbuild-all@01.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:61546
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753143AbdERCBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 22:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It may be worth checking on these.  The code context is shown in the first
case (line 120).  For the others, at least it gives the line numbers.

julia

---------- Forwarded message ----------
Date: Thu, 18 May 2017 09:07:31 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: [net:master 9/12] net/ipv6/ip6_offload.c:120:7-21: WARNING: Unsigned
    expression compared with zero: unfrag_ip6hlen < 0

CC: kbuild-all@01.org
CC: netdev@vger.kernel.org
TO: Craig Gallek <kraig@google.com>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   579f1d926c66cc0bd3bd87b1fe2e091084b07430
commit: 2423496af35d94a87156b063ea5cedffc10a70a1 [9/12] ipv6: Prevent overrun when parsing v6 header options
:::::: branch date: 2 hours ago
:::::: commit date: 6 hours ago

>> net/ipv6/ip6_offload.c:120:7-21: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0
--
>> net/ipv6/ip6_output.c:601:5-9: WARNING: Unsigned expression compared with zero: hlen < 0
--
>> net/ipv6/udp_offload.c:94:6-20: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0

git remote add net https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
git remote update net
git checkout 2423496af35d94a87156b063ea5cedffc10a70a1
vim +120 net/ipv6/ip6_offload.c

d1da932e Vlad Yasevich        2012-11-15  104
07b26c94 Steffen Klassert     2016-09-19  105  	gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
07b26c94 Steffen Klassert     2016-09-19  106
d1da932e Vlad Yasevich        2012-11-15  107  	for (skb = segs; skb; skb = skb->next) {
d3e5e006 Eric Dumazet         2013-10-20  108  		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
07b26c94 Steffen Klassert     2016-09-19  109  		if (gso_partial)
802ab55a Alexander Duyck      2016-04-10  110  			payload_len = skb_shinfo(skb)->gso_size +
802ab55a Alexander Duyck      2016-04-10  111  				      SKB_GSO_CB(skb)->data_offset +
802ab55a Alexander Duyck      2016-04-10  112  				      skb->head - (unsigned char *)(ipv6h + 1);
802ab55a Alexander Duyck      2016-04-10  113  		else
802ab55a Alexander Duyck      2016-04-10  114  			payload_len = skb->len - nhoff - sizeof(*ipv6h);
802ab55a Alexander Duyck      2016-04-10  115  		ipv6h->payload_len = htons(payload_len);
d3e5e006 Eric Dumazet         2013-10-20  116  		skb->network_header = (u8 *)ipv6h - skb->head;
d3e5e006 Eric Dumazet         2013-10-20  117
91a48a2e Hannes Frederic Sowa 2014-02-24  118  		if (udpfrag) {
d1da932e Vlad Yasevich        2012-11-15  119  			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
2423496a Craig Gallek         2017-05-16 @120  			if (unfrag_ip6hlen < 0)
2423496a Craig Gallek         2017-05-16  121  				return ERR_PTR(unfrag_ip6hlen);
d3e5e006 Eric Dumazet         2013-10-20  122  			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
d1da932e Vlad Yasevich        2012-11-15  123  			fptr->frag_off = htons(offset);
53b24b8f Ian Morris           2015-03-29  124  			if (skb->next)
d1da932e Vlad Yasevich        2012-11-15  125  				fptr->frag_off |= htons(IP6_MF);
d1da932e Vlad Yasevich        2012-11-15  126  			offset += (ntohs(ipv6h->payload_len) -
d1da932e Vlad Yasevich        2012-11-15  127  				   sizeof(struct frag_hdr));
d1da932e Vlad Yasevich        2012-11-15  128  		}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
