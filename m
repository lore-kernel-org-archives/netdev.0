From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: enforce egress device match in per table
 nexthop lookups
Date: Mon, 27 Jun 2016 10:37:44 -0400 (EDT)
Message-ID: <20160627.103744.1096333711221016004.davem@davemloft.net>
References: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	bgalvani@redhat.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbcF0OiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:38:14 -0400
In-Reply-To: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 23 Jun 2016 15:25:09 +0200

> with the commit 8c14586fc320 ("net: ipv6: Use passed in table for
> nexthop lookups"), net hop lookup is first performed on route creation
> in the passed-in table.
> However device match is not enforced in table lookup, so the found
> route can be later discarded due to egress device mismatch and no
> global lookup will be performed.
> This cause the following to fail:
> 
> ip link add dummy1 type dummy
> ip link add dummy2 type dummy
> ip link set dummy1 up
> ip link set dummy2 up
> ip route add 2001:db8:8086::/48 dev dummy1 metric 20
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy1 metric 20
> ip route add 2001:db8:8086::/48 dev dummy2 metric 21
> ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy2 metric 21
> RTNETLINK answers: No route to host
> 
> This change fixes the issue enforcing device lookup in
> ip6_nh_lookup_table()
> 
> v1->v2: updated commit message title
> 
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Reported-and-tested-by: Beniamino Galvani <bgalvani@redhat.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
