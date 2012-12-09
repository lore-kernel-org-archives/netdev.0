From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 195/198] net/bridge/br_mdb.c:79:35: sparse:
 incompatible types in comparison expression (different address spaces)
Date: Sun, 09 Dec 2012 10:54:22 +0800
Message-ID: <50c3fd5e.qB65a7/5e+IZT2ix%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11820 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030353Ab2LICzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2012 21:55:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   9ecb9aabaf634677c77af467f4e3028b09d7bcda
commit: ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 [195/198] bridge: export multicast database via netlink


sparse warnings:

+ net/bridge/br_mdb.c:79:35: sparse: incompatible types in comparison expression (different address spaces)

vim +79 net/bridge/br_mdb.c

ee07c6e7 Cong Wang 2012-12-07  63  		struct hlist_node *h;
ee07c6e7 Cong Wang 2012-12-07  64  		struct net_bridge_mdb_entry *mp;
ee07c6e7 Cong Wang 2012-12-07  65  		struct net_bridge_port_group *p, **pp;
ee07c6e7 Cong Wang 2012-12-07  66  		struct net_bridge_port *port;
ee07c6e7 Cong Wang 2012-12-07  67  
ee07c6e7 Cong Wang 2012-12-07  68  		hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
ee07c6e7 Cong Wang 2012-12-07  69  			if (idx < s_idx)
ee07c6e7 Cong Wang 2012-12-07  70  				goto skip;
ee07c6e7 Cong Wang 2012-12-07  71  
ee07c6e7 Cong Wang 2012-12-07  72  			nest2 = nla_nest_start(skb, MDBA_MDB_ENTRY);
ee07c6e7 Cong Wang 2012-12-07  73  			if (nest2 == NULL) {
ee07c6e7 Cong Wang 2012-12-07  74  				err = -EMSGSIZE;
ee07c6e7 Cong Wang 2012-12-07  75  				goto out;
ee07c6e7 Cong Wang 2012-12-07  76  			}
ee07c6e7 Cong Wang 2012-12-07  77  
ee07c6e7 Cong Wang 2012-12-07  78  			for (pp = &mp->ports;
ee07c6e7 Cong Wang 2012-12-07 @79  			     (p = rcu_dereference(*pp)) != NULL;
ee07c6e7 Cong Wang 2012-12-07  80  			      pp = &p->next) {
ee07c6e7 Cong Wang 2012-12-07  81  				port = p->port;
ee07c6e7 Cong Wang 2012-12-07  82  				if (port) {
ee07c6e7 Cong Wang 2012-12-07  83  					struct br_mdb_entry e;
ee07c6e7 Cong Wang 2012-12-07  84  					e.ifindex = port->dev->ifindex;
ee07c6e7 Cong Wang 2012-12-07  85  					e.addr.u.ip4 = p->addr.u.ip4;
ee07c6e7 Cong Wang 2012-12-07  86  #if IS_ENABLED(CONFIG_IPV6)
ee07c6e7 Cong Wang 2012-12-07  87  					e.addr.u.ip6 = p->addr.u.ip6;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
