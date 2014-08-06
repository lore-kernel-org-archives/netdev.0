From: Dave Jones <davej@redhat.com>
Subject: ip6tables filter breakage.
Date: Wed, 6 Aug 2014 15:52:22 -0400
Message-ID: <20140806195222.GA10618@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbaHFTwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 15:52:30 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s76JqTjU002326
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2014 15:52:29 -0400
Received: from gelk.kernelslacker.org (ovpn-113-45.phx2.redhat.com [10.3.113.45])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s76JqNDR029348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2014 15:52:28 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s76JqMWB012126
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2014 15:52:22 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s76JqMPC012125
	for netdev@vger.kernel.org; Wed, 6 Aug 2014 15:52:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After updating to Linus' current tree with todays net/ merge,
I noticed that ip6tables doesn't work any more..

# ip6tables -F
ip6tables v1.4.19.1: can't initialize ip6tables table `filter': No
chain/target/match by that name
Perhaps ip6tables or your kernel needs to be upgraded

My config has CONFIG_IP6_NF_FILTER=m
I also note that ip6table_filter.ko doesn't get auto-loaded now.
But even after modprobing it, I get the same message.

Is there some additional option I now need to enable ?


I was a little surprised by how CONFIG_NF_TABLES is mandatory
for iptables to keep working, even if you don't have nft userspace.
(The only relevant thing in the Kconfig was related to x_tables,
 which I wasn't using).

Perhaps either some select's, or additional help text ?

	Dave
