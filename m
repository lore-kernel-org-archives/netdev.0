From: David Miller <davem@davemloft.net>
Subject: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:33:42 -0400 (EDT)
Message-ID: <20110517.143342.1566027350038182221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756133Ab1EQSdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:33:44 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4HIXg99004119
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 11:33:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems to me that we can solve the UDP fragmentation problem for
flow steering very simply by creating a (saddr/daddr/IPID) entry in a
table that maps to the corresponding RPS flow entry.

When we see the initial frag with the UDP header, we create the
saddr/daddr/IPID mapping, and we tear it down when we hit the
saddr/daddr/IPID mapping and the packet has the IP_MF bit clear.

We only inspect the saddr/daddr/IPID cache when iph->frag_off is
non-zero.

It's best effort and should work quite well.

Even a one-behind cache, per-NAPI instance, would do a lot better than
what happens at the moment.  Especially since the IP fragments mostly
arrive as one packet train.
