From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision
 defined
Date: Tue, 24 Feb 2015 16:31:37 -0500 (EST)
Message-ID: <20150224.163137.12835478467735127.davem@davemloft.net>
References: <1424794259-30241-2-git-send-email-johunt@akamai.com>
	<20150224.131828.1632037288300527014.davem@davemloft.net>
	<54ECD57A.1080709@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, pablo@netfilter.org, kaber@trash.net,
	tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbBXVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:31:39 -0500
In-Reply-To: <54ECD57A.1080709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 24 Feb 2015 20:48:10 +0100

> On 02/24/2015 07:18 PM, David Miller wrote:
> ...
>> I've already said today that I think this whole indirection stuff
>> with grow and shrink decisions should simply go away.
>>
>> Everyone defines it to the generic rhashtable routine, therefore
>> that should just be made private to lib/rhashtable.c, called
>> directly, and the methods completely removed.
>>
>> Given that, this change makes no sense.
>>
>> When a limit is not specified, we should unconditionally grow rather
>> than refuse to grow.  One should not be required to specify this at
>> all.  If you have no idea what limit might be reasonable, you specify
>> nothing at all and just let available memory be the limiting factor.
> 
> I agree.
> 
> Fwiw, I believe this behavior came in as a regression via commit
> c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for worker
> queue").
> Initially, if no max_shift was specified, we'd just expand further.
> 
> I can take care of these above two fixups tomorrow, if you want.
> I presume you want to route both via -net, or just the growth limit
> issue via -net?

Let's fix as much crap as we can in -net.  I'm going to have to do
a huge backport of all the rhashtables to -stable at some point
too.

> I also have some optimizations I was working on last week for
> net-next, but I would wait for a -net into -net-next merge after
> that to avoid merge conflicts, if that's fine. ;)

Yes, good idea :)
