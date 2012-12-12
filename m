From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 14/17] net/bridge/br_mdb.c:330
 br_mdb_add_group() error: potential null dereference 'mp'.
  (br_multicast_new_group returns null)
Date: Thu, 13 Dec 2012 03:21:49 +0800
Message-ID: <50c8d94d.VSxb5ulWJHo9Ahhi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19760 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754049Ab2LLTY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 14:24:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   520dfe3a3645257bf83660f672c47f8558f3d4c4
commit: cfd567543590f71ca0af397437e2554f9756d750 [14/17] bridge: add support of adding and deleting mdb entries


smatch warnings:

+ net/bridge/br_mdb.c:330 br_mdb_add_group() error: potential null dereference 'mp'.  (br_multicast_new_group returns null)

vim +330 +/mp net/bridge/br_mdb.c

cfd56754 Cong Wang 2012-12-11  314  {
cfd56754 Cong Wang 2012-12-11  315  	struct net_bridge_mdb_entry *mp;
cfd56754 Cong Wang 2012-12-11  316  	struct net_bridge_port_group *p;
cfd56754 Cong Wang 2012-12-11  317  	struct net_bridge_port_group __rcu **pp;
cfd56754 Cong Wang 2012-12-11  318  	struct net_bridge_mdb_htable *mdb;
cfd56754 Cong Wang 2012-12-11  319  	int err;
cfd56754 Cong Wang 2012-12-11  320  
cfd56754 Cong Wang 2012-12-11  321  	mdb = mlock_dereference(br->mdb, br);
cfd56754 Cong Wang 2012-12-11  322  	mp = br_mdb_ip_get(mdb, group);
cfd56754 Cong Wang 2012-12-11  323  	if (!mp) {
cfd56754 Cong Wang 2012-12-11  324  		mp = br_multicast_new_group(br, port, group);
cfd56754 Cong Wang 2012-12-11  325  		err = PTR_ERR(mp);
cfd56754 Cong Wang 2012-12-11  326  		if (IS_ERR(mp))
cfd56754 Cong Wang 2012-12-11  327  			return err;
cfd56754 Cong Wang 2012-12-11  328  	}
cfd56754 Cong Wang 2012-12-11  329  
cfd56754 Cong Wang 2012-12-11 @330  	for (pp = &mp->ports;
cfd56754 Cong Wang 2012-12-11  331  	     (p = mlock_dereference(*pp, br)) != NULL;
cfd56754 Cong Wang 2012-12-11  332  	     pp = &p->next) {
cfd56754 Cong Wang 2012-12-11  333  		if (p->port == port)
cfd56754 Cong Wang 2012-12-11  334  			return -EEXIST;
cfd56754 Cong Wang 2012-12-11  335  		if ((unsigned long)p->port < (unsigned long)port)
cfd56754 Cong Wang 2012-12-11  336  			break;
cfd56754 Cong Wang 2012-12-11  337  	}
cfd56754 Cong Wang 2012-12-11  338  

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
