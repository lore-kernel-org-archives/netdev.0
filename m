From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 33/50] net/ipv4/ipip.c:867:34: sparse: incorrect type in assignment (different base types)
Date: Thu, 15 Nov 2012 13:16:48 +0800
Message-ID: <50a47ac0.a2q7mGhdQ7lwFkgq%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33484 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab2KOFRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 00:17:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   702ed3c1a9dfe4dfe112f13542d0c9d689f5008b
commit: be42da0e1012bf67d8f6899b7d9162e35527da4b [33/50] ipip: add support of link creation via rtnl


sparse warnings:

+ net/ipv4/ipip.c:867:34: sparse: incorrect type in assignment (different base types)
net/ipv4/ipip.c:867:34:    expected restricted __be32 [usertype] saddr
net/ipv4/ipip.c:867:34:    got unsigned int
net/ipv4/ipip.c:870:34: sparse: incorrect type in assignment (different base types)
net/ipv4/ipip.c:870:34:    expected restricted __be32 [usertype] daddr
net/ipv4/ipip.c:870:34:    got unsigned int

vim +867 net/ipv4/ipip.c

be42da0e Nicolas Dichtel 2012-11-14  851  static void ipip_netlink_parms(struct nlattr *data[],
be42da0e Nicolas Dichtel 2012-11-14  852  			       struct ip_tunnel_parm *parms)
be42da0e Nicolas Dichtel 2012-11-14  853  {
be42da0e Nicolas Dichtel 2012-11-14  854  	memset(parms, 0, sizeof(*parms));
be42da0e Nicolas Dichtel 2012-11-14  855  
be42da0e Nicolas Dichtel 2012-11-14  856  	parms->iph.version = 4;
be42da0e Nicolas Dichtel 2012-11-14  857  	parms->iph.protocol = IPPROTO_IPIP;
be42da0e Nicolas Dichtel 2012-11-14  858  	parms->iph.ihl = 5;
be42da0e Nicolas Dichtel 2012-11-14  859  
be42da0e Nicolas Dichtel 2012-11-14  860  	if (!data)
be42da0e Nicolas Dichtel 2012-11-14  861  		return;
be42da0e Nicolas Dichtel 2012-11-14  862  
be42da0e Nicolas Dichtel 2012-11-14  863  	if (data[IFLA_IPTUN_LINK])
be42da0e Nicolas Dichtel 2012-11-14  864  		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
be42da0e Nicolas Dichtel 2012-11-14  865  
be42da0e Nicolas Dichtel 2012-11-14  866  	if (data[IFLA_IPTUN_LOCAL])
be42da0e Nicolas Dichtel 2012-11-14 @867  		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
be42da0e Nicolas Dichtel 2012-11-14  868  
be42da0e Nicolas Dichtel 2012-11-14  869  	if (data[IFLA_IPTUN_REMOTE])
be42da0e Nicolas Dichtel 2012-11-14  870  		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
be42da0e Nicolas Dichtel 2012-11-14  871  
be42da0e Nicolas Dichtel 2012-11-14  872  	if (data[IFLA_IPTUN_TTL]) {
be42da0e Nicolas Dichtel 2012-11-14  873  		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
be42da0e Nicolas Dichtel 2012-11-14  874  		if (parms->iph.ttl)
be42da0e Nicolas Dichtel 2012-11-14  875  			parms->iph.frag_off = htons(IP_DF);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
