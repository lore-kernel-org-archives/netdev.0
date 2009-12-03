From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7] Batched netns improvements.
Date: Thu, 03 Dec 2009 05:23:05 -0800
Message-ID: <m1fx7smbt2.fsf@fess.ebiederm.org>
References: <m11vjcnsyr.fsf@fess.ebiederm.org> <1259845591.3766.30.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42708 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbZLCNXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:23:06 -0500
In-Reply-To: <1259845591.3766.30.camel@bigi> (jamal's message of "Thu\, 03 Dec 2009 08\:06\:31 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:

> On Thu, 2009-12-03 at 04:27 -0800, Eric W. Biederman wrote:
>> This series of patches takes my simple 4k network namespace exit test
>> from about 44s to 1.6s, with a minuscule increase in code side.
>
> Nice.
> I will test these as soon as they make it into net-next (just easier
> for me given the setup).
> I should confirm that:
> The previous patches which are already in net-next from yesterday do
> improve performance to under 1 minute. Can we call that a several-factor
> improvement?;->
>
> Are you planning to give some tender loving to the virtual devices 
> as well (gre etc) or is that taken care of now you have a pernet batch
> exit op?

The tunnel devices gre, ipip, sit, ip6_tunnel, and the ethernet
bridging still need some tlc to give them rtnl_link_ops, and in
particular dellink operations so the deletions can be done in one big
batch.

The batch operations are mostly a generalization of a bunch of what
was already there.

I keep planning on doing something else and then I wind up working on
this.

Mostly what I have done turned out to be some very low hanging fruit,
and some general cleanups.

Eric

