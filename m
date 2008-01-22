From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 0/9] TRIE performance patches
Date: Tue, 22 Jan 2008 15:37:33 -0800
Message-ID: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33079 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756871AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Time to handle a full BGP load (163K of routes).

Before:		Load		Dump		Flush
hash		3.5		 0.5		0.7
2.6.23.14	3.4		19.3		10.3
net-2.6.25	3.4		18.7		9.8

After:
kmem_cache	3.8		13.0		7.2
iter		3.9		12.3		6.9
unordered	3.1		11.9		4.9
find_node	3.1		 0.3		1.2

Load:	ip -batch iproute-table
Dump:	ip route >/dev/null
Flush:	ip route flush table main
-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

