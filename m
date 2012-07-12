From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 90/102] net/ipv4/route.c:1283:9: warning: unused
 variable 'saddr'
Date: Thu, 12 Jul 2012 22:34:49 +0800
Message-ID: <20120712143449.GA19890@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36714 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932585Ab2GLOe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 10:34:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

There are new compile warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   3ec5a261aef55a32664bffd335e5c32aeadf3215
commit: e47a185b31dd2acd424fac7dc0efb96fc5b31a33 [90/102] ipv4: Generalize ip_do_redirect() and hook into new dst_ops->redirect.

All warnings:

net/ipv4/route.c: In function 'ip_do_redirect':
net/ipv4/route.c:1283:9: warning: unused variable 'saddr' [-Wunused-variable]
net/ipv4/route.c:1282:9: warning: unused variable 'daddr' [-Wunused-variable]

vim +1283 net/ipv4/route.c
  1280		__be32 old_gw = ip_hdr(skb)->saddr;
  1281		struct net_device *dev = skb->dev;
  1282		__be32 daddr = iph->daddr;
> 1283		__be32 saddr = iph->saddr;
  1284		struct in_device *in_dev;
  1285		struct neighbour *n;
  1286		struct rtable *rt;

..because the saddr/daddr variables are used inside

#ifdef CONFIG_IP_ROUTE_VERBOSE
        if (IN_DEV_LOG_MARTIANS(in_dev))
                net_info_ratelimited("Redirect from %pI4 on %s about %pI4 ignored\n"
                                     "  Advised path = %pI4 -> %pI4\n",
                                     &old_gw, dev->name, &new_gw,
                                     &saddr, &daddr);
#endif

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation
