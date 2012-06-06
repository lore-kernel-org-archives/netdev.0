From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Possible deadlock in ipv6?
Date: Wed, 6 Jun 2012 18:49:24 +0400
Message-ID: <4FCF6DF4.2090304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:42060 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab2FFOt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 10:49:26 -0400
Received: from msk-exch1.sw.swsoft.com ([10.30.1.231] helo=mail.sw.ru)
	by relay.parallels.com with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.77)
	(envelope-from <VDavydov@parallels.com>)
	id 1ScHY5-0008Tx-8S
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 18:49:25 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not familiar with the linux net subsystem, so I would appreciate if 
someone could clarify if the following call chain is possible:

addrconf_ifdown() calls neigh_ifdown(nd_tbl) which locks nd_tbl.lock for 
writing and calls

     pneigh_ifdown
     pndisc_destructor
     ipv6_dev_mc_dec
     __ipv6_dev_mc_dec
     igmp6_group_dropped
     igmp6_leave_group
     igmp6_send
     icmp6_dst_alloc
     ip6_neigh_lookup
     neigh_create

and neigh_create() locks nd_tbl.lock for writing again resulting in a 
deadlock.

Thank you.
