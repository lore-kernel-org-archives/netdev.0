From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: IPv6: Fix not join all-router mcast group when forwarding set.
Date: Wed, 7 Mar 2012 14:45:02 +0300
Message-ID: <20120307114502.GA13204@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:18610 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab2CGLpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 06:45:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Li Wei,

This is a semi-automatic email about new static checker warnings.

The patch d6ddef9e641d: "IPv6: Fix not join all-router mcast group 
when forwarding set." from Mar 5, 2012, leads to the following Smatch 
complaint:

net/ipv6/addrconf.c:438 ipv6_add_dev()
	 warn: variable dereferenced before check 'dev' (see line 432)

net/ipv6/addrconf.c
   431		/* protected by rtnl_lock */
   432		rcu_assign_pointer(dev->ip6_ptr, ndev);
                                   ^^^^^^^^^^^^
Old dereference.

   433	
   434		/* Join all-node multicast group */
   435		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
   436	
   437		/* Join all-router multicast group if forwarding is set */
   438		if (ndev->cnf.forwarding && dev && (dev->flags & IFF_MULTICAST))
                                            ^^^

New check.  Probably you can just remove the check?

   439			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
   440	

regards,
dan carpenter
