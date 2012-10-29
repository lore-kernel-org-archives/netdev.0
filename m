From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 86/92] net/ipv6/addrconf.c:557 dev_forward_change()
 error: we previously assumed 'dev' could be null (see line 541)
Date: Mon, 29 Oct 2012 09:57:09 +0800
Message-ID: <20121029015709.GA18567@localhost>
References: <508ddd10.Fq4xdOIJOPuT2J+A%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756328Ab2J2B5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 21:57:11 -0400
Content-Disposition: inline
In-Reply-To: <508ddd10.Fq4xdOIJOPuT2J+A%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

FYI, there are new smatch warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   a932657f51eadb8280166e82dc7034dfbff3985a
commit: f3a1bfb11ccbc72d44f0b58c92115a40128979c3 [86/92] rtnl/ipv6: use netconf msg to advertise forwarding status

  net/ipv6/addrconf.c:394 ipv6_add_dev() warn: 'dev' held on error path.
+ net/ipv6/addrconf.c:557 dev_forward_change() error: we previously assumed 'dev' could be null (see line 541)
  net/ipv6/addrconf.c:885 ipv6_del_addr() error: potential NULL dereference 'rt'.

vim +557 +/dev net/ipv6/addrconf.c

^1da177e Linus Torvalds    2005-04-16  535  
^1da177e Linus Torvalds    2005-04-16  536  	if (!idev)
^1da177e Linus Torvalds    2005-04-16  537  		return;
^1da177e Linus Torvalds    2005-04-16  538  	dev = idev->dev;
0187bdfb Ben Hutchings     2008-06-19  539  	if (idev->cnf.forwarding)
0187bdfb Ben Hutchings     2008-06-19  540  		dev_disable_lro(dev);
^1da177e Linus Torvalds    2005-04-16 @541  	if (dev && (dev->flags & IFF_MULTICAST)) {
^1da177e Linus Torvalds    2005-04-16  542  		if (idev->cnf.forwarding)
f3ee4010 YOSHIFUJI Hideaki 2008-04-10  543  			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
^1da177e Linus Torvalds    2005-04-16  544  		else
f3ee4010 YOSHIFUJI Hideaki 2008-04-10  545  			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
^1da177e Linus Torvalds    2005-04-16  546  	}
502a2ffd stephen hemminger 2010-03-17  547  
502a2ffd stephen hemminger 2010-03-17  548  	list_for_each_entry(ifa, &idev->addr_list, if_list) {
2c12a74c Michal Wrobel     2007-02-26  549  		if (ifa->flags&IFA_F_TENTATIVE)
2c12a74c Michal Wrobel     2007-02-26  550  			continue;
^1da177e Linus Torvalds    2005-04-16  551  		if (idev->cnf.forwarding)
^1da177e Linus Torvalds    2005-04-16  552  			addrconf_join_anycast(ifa);
^1da177e Linus Torvalds    2005-04-16  553  		else
^1da177e Linus Torvalds    2005-04-16  554  			addrconf_leave_anycast(ifa);
^1da177e Linus Torvalds    2005-04-16  555  	}
f3a1bfb1 Nicolas Dichtel   2012-10-25  556  	inet6_netconf_notify_devconf(dev_net(dev), NETCONFA_FORWARDING,
f3a1bfb1 Nicolas Dichtel   2012-10-25 @557  				     dev->ifindex, &idev->cnf);
^1da177e Linus Torvalds    2005-04-16  558  }
^1da177e Linus Torvalds    2005-04-16  559  
^1da177e Linus Torvalds    2005-04-16  560  

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
