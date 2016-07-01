From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bonding: prevent out of bound accesses
Date: Fri, 01 Jul 2016 06:06:25 -0400 (EDT)
Message-ID: <20160701.060625.403590393376125450.davem@davemloft.net>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, nikolay@redhat.com,
	dingtianhong@huawei.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbcGAKHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 06:07:24 -0400
In-Reply-To: <1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Jun 2016 16:13:41 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ether_addr_equal_64bits() requires some care about its arguments,
> namely that 8 bytes might be read, even if last 2 byte values are not
> used.
> 
> KASan detected a violation with null_mac_addr and lacpdu_mcast_addr
> in bond_3ad.c
> 
> Same problem with mac_bcast[] and mac_v6_allmcast[] in bond_alb.c :
> Although the 8-byte alignment was there, KASan would detect out
> of bound accesses.
> 
> Fixes: 815117adaf5b ("bonding: use ether_addr_equal_unaligned for bond addr compare")
> Fixes: bb54e58929f3 ("bonding: Verify RX LACPDU has proper dest mac-addr")
> Fixes: 885a136c52a8 ("bonding: use compare_ether_addr_64bits() in ALB")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied, thanks Eric.
