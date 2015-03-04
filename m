From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Neighbour table prep for MPLS
Date: Wed, 04 Mar 2015 16:04:35 -0500 (EST)
Message-ID: <20150304.160435.285431782284502041.davem@davemloft.net>
References: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<20150304.002502.1950561993507910047.davem@davemloft.net>
	<87pp8pqpf2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbbCDVEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:04:36 -0500
In-Reply-To: <87pp8pqpf2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Mar 2015 23:53:21 -0600

> We could potentially translate the numbers into the enumeration that is
> NEIGH_ARP_TABLE, NEIGH_ND_TABLE, and NEIGH_DN_TABLE.  Or waste a little
> bit of memory in have a 30 entry array and looking things up by address
> protocol number.   The only disadvantage I can see to using AF_NNN as
> the index is that it might be a little less cache friendly.

Yes, you can just store NEIGH_*_TABLE in your route entries and
pass that directly into neigh_xmit(), or something like that.

> Other issues the hh header cache doesn't work. (How much do we care).
> 
> I worry a little that supporting AF_PACKET case might cause problems
> in the future.
> 
> The cumulus folks are probably going to want to use neigh_xmit so they
> can have ipv6 nexthops on ipv4.  Using this for IPv4 and loosing the
> header cache worries me a little.

We can have variable hard header caches per neigh entry if we really
want to.  The only issue is, again, making the demux simple.
