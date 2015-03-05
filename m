From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/2] Neighbour table prep for MPLS
Date: Thu, 05 Mar 2015 06:35:00 -0600
Message-ID: <87twxzipvv.fsf@x220.int.ebiederm.org>
References: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<20150304.002502.1950561993507910047.davem@davemloft.net>
	<87pp8pqpf2.fsf@x220.int.ebiederm.org>
	<20150304.160435.285431782284502041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Andy Gospodarek <gospo@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48728 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbbCEMif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 07:38:35 -0500
In-Reply-To: <20150304.160435.285431782284502041.davem@davemloft.net> (David
	Miller's message of "Wed, 04 Mar 2015 16:04:35 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 03 Mar 2015 23:53:21 -0600
>
>> We could potentially translate the numbers into the enumeration that is
>> NEIGH_ARP_TABLE, NEIGH_ND_TABLE, and NEIGH_DN_TABLE.  Or waste a little
>> bit of memory in have a 30 entry array and looking things up by address
>> protocol number.   The only disadvantage I can see to using AF_NNN as
>> the index is that it might be a little less cache friendly.
>
> Yes, you can just store NEIGH_*_TABLE in your route entries and
> pass that directly into neigh_xmit(), or something like that.

And using the NEIGH_*_TABLE defines doesn't look too bad.  I walked a
little ways down the path of what would it take to remove NEIGH_*_TABLE
altogether and replacing NEIGH_*_TABLE with AF_* but the loops that are
for each possible neighbout table made just seemed to horrible to
convert that way.

So I now have an implementation that changes my routing tables to hold
NEIGH_*_ and it doesn't look bad at all.  Especially given that I
already have to filter the address families who's neighbour tables I can
use.

>> Other issues the hh header cache doesn't work. (How much do we care).
>> 
>> I worry a little that supporting AF_PACKET case might cause problems
>> in the future.
>> 
>> The cumulus folks are probably going to want to use neigh_xmit so they
>> can have ipv6 nexthops on ipv4.  Using this for IPv4 and loosing the
>> header cache worries me a little.
>
> We can have variable hard header caches per neigh entry if we really
> want to.  The only issue is, again, making the demux simple.

This is where things start creeping up on benchmarking that is really
more work than I am ready to take on for this project.

I think it would be really interesting to know if the hardware header
caches are worth it, and if they are is it only because it avoids a
function pointer or because all of our data comes from the same cache
line.

Looking at the code I find it interesting that we reserve less space
for the hardware header than we do for the hardware address itself.

Optimization opportunities clearly abound.

Eric
