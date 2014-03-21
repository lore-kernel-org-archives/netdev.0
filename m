From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Fri, 21 Mar 2014 15:28:36 -0400 (EDT)
Message-ID: <20140321.152836.1010161671166010422.davem@davemloft.net>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
	<20140319.155930.1805664690676428310.davem@davemloft.net>
	<1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: VenkatKumar.Duvvuru@Emulex.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbaCUT2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 15:28:38 -0400
In-Reply-To: <1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 21 Mar 2014 14:33:13 +0000

> On Wed, 2014-03-19 at 15:59 -0400, David Miller wrote:
>> From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
>> Date: Mon, 17 Mar 2014 18:01:33 +0530
>> 
>> > NIC drivers that support RSS use either a hard-coded value or a random value for
>> > the RSS hash key. Irrespective of the type of the key used, the user would want
>> > to change the hash key if he/she is not satisfied with the effectiveness of the
>> > default hash-key in spreading the incoming flows evenly across the RSS queues.
>> > 
>> > This patch set adds support for configuring the RSS hash-key via the ethtool
>> > interface using -X option.
>> 
>> I apologize, but I really dislike this.  For several reasons.
>> 
>> First, why aren't we adding _just_ a RSS hash changing interface?
>>
>> We already have an interface for changing the indirection table,
>> there is absolutely not need to add a second interface that supports
>> both indirection table _plus_ hash modifications.
> 
> That's what I asked for, because I see the hash key and indirection
> table as being a single logical object (RSS context).
> 
>> And combining these two is what leads to this hard to audit, ugly,
>> data structure layout.
>> 
>> There's the indirection table at some offset, then the key at some
>> other offset.  This makes it impossible to impose type checking
>> of any kind on both objects.
> [...]
> 
> Which is why I previously suggested making the ethtool core find the two
> arrays and pass those into the driver operations.  We do that for other
> ethtool operations that use even a single variable-length array.

Sure, we could hide the dirt in the generic ethtool code and pass
separated out pointers to the drivers.

But you have to recognize that the dirt will still exist in userspace
when it calls this stuff.

Nothing stops ethtool from providing a combined operation on the
command line, but that doesn't mean we necessarily have to have
a single kernel interface doing both thing.

I really still think that adding just a new key operation is the way
to go.
