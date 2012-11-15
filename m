From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 37/50] net/ipv6/sit.c:1243:34: sparse: incorrect type in assignment (different base types)
Date: Thu, 15 Nov 2012 13:42:22 +0800
Message-ID: <50a480be.gHpxrfRWyxrf9cw9%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46692 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab2KOFmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 00:42:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   702ed3c1a9dfe4dfe112f13542d0c9d689f5008b
commit: f37234160233561f2a2e3332272ae5b3725b620b [37/50] sit: add support of link creation via rtnl


sparse warnings:

net/ipv6/sit.c:231:21: sparse: restricted __be16 degrades to integer
+ net/ipv6/sit.c:1243:34: sparse: incorrect type in assignment (different base types)
net/ipv6/sit.c:1243:34:    expected restricted __be32 [usertype] saddr
net/ipv6/sit.c:1243:34:    got unsigned int
net/ipv6/sit.c:1246:34: sparse: incorrect type in assignment (different base types)
net/ipv6/sit.c:1246:34:    expected restricted __be32 [usertype] daddr
net/ipv6/sit.c:1246:34:    got unsigned int
net/ipv6/sit.c:1261:32: sparse: incorrect type in assignment (different base types)
net/ipv6/sit.c:1261:32:    expected restricted __be16 [usertype] i_flags
net/ipv6/sit.c:1261:32:    got unsigned short
net/ipv6/sit.c:1340:52: sparse: incorrect type in argument 3 (different base types)
net/ipv6/sit.c:1340:52:    expected unsigned short [unsigned] [usertype] value
net/ipv6/sit.c:1340:52:    got restricted __be16 [usertype] i_flags

vim +1243 net/ipv6/sit.c

f3723416 Nicolas Dichtel 2012-11-14  1227  				struct ip_tunnel_parm *parms)
f3723416 Nicolas Dichtel 2012-11-14  1228  {
f3723416 Nicolas Dichtel 2012-11-14  1229  	memset(parms, 0, sizeof(*parms));
f3723416 Nicolas Dichtel 2012-11-14  1230  
f3723416 Nicolas Dichtel 2012-11-14  1231  	parms->iph.version = 4;
f3723416 Nicolas Dichtel 2012-11-14  1232  	parms->iph.protocol = IPPROTO_IPV6;
f3723416 Nicolas Dichtel 2012-11-14  1233  	parms->iph.ihl = 5;
f3723416 Nicolas Dichtel 2012-11-14  1234  	parms->iph.ttl = 64;
f3723416 Nicolas Dichtel 2012-11-14  1235  
f3723416 Nicolas Dichtel 2012-11-14  1236  	if (!data)
f3723416 Nicolas Dichtel 2012-11-14  1237  		return;
f3723416 Nicolas Dichtel 2012-11-14  1238  
f3723416 Nicolas Dichtel 2012-11-14  1239  	if (data[IFLA_IPTUN_LINK])
f3723416 Nicolas Dichtel 2012-11-14  1240  		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
f3723416 Nicolas Dichtel 2012-11-14  1241  
f3723416 Nicolas Dichtel 2012-11-14  1242  	if (data[IFLA_IPTUN_LOCAL])
f3723416 Nicolas Dichtel 2012-11-14 @1243  		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
f3723416 Nicolas Dichtel 2012-11-14  1244  
f3723416 Nicolas Dichtel 2012-11-14  1245  	if (data[IFLA_IPTUN_REMOTE])
f3723416 Nicolas Dichtel 2012-11-14  1246  		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
f3723416 Nicolas Dichtel 2012-11-14  1247  
f3723416 Nicolas Dichtel 2012-11-14  1248  	if (data[IFLA_IPTUN_TTL]) {
f3723416 Nicolas Dichtel 2012-11-14  1249  		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
f3723416 Nicolas Dichtel 2012-11-14  1250  		if (parms->iph.ttl)
f3723416 Nicolas Dichtel 2012-11-14  1251  			parms->iph.frag_off = htons(IP_DF);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
