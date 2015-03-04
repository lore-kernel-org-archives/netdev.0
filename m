From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Neighbour table prep for MPLS
Date: Wed, 04 Mar 2015 00:25:02 -0500 (EST)
Message-ID: <20150304.002502.1950561993507910047.davem@davemloft.net>
References: <87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbbCDFZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:25:04 -0500
In-Reply-To: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Mar 2015 17:09:35 -0600

> In preparation for using the IPv4 and IPv6 neighbour tables in my mpls
> code this patchset factors out ___neigh_lookup_noref from
> __ipv4_neigh_lookup_noref, __ipv6_lookup_noref and neigh_lookup.
> Allowing the lookup logic to be shared between the different
> implementations.  At what appears to be no cost. (Aka the same assembly
> is generated for ip6_finish_output2 and ip_finish_output2).
> 
> After that I add a simple function that takes an address family and an
> address consults the neighbour table and sends the packet to the
> appropriate location.  The address family argument decoupls callers
> of neigh_xmit from the addresses families the packets are sent over.
> (Aka The ipv6 module can be loaded after mpls and a previously
> configured ipv6 next hop will start working).
> 
> The refactoring in ___neigh_lookup_noref may be a bit overkill but it
> feels like the right thing to do.  Especially since the same code is
> generated.

Series applied, thanks.

Maybe we can make neigh_table_find() faster by making it a direct
array demux of some kind instead of some switch statment thing?
It's the only think I don't like about neigh_xmit().
