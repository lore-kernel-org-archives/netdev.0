From: David Miller <davem@davemloft.net>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 07 Oct 2014 13:19:38 -0400 (EDT)
Message-ID: <20141007.131938.1410434352331637585.davem@davemloft.net>
References: <20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	<1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, brouer@redhat.com,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbaJGRTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:19:42 -0400
In-Reply-To: <1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Oct 2014 08:01:20 -0700

> On Tue, 2014-10-07 at 16:43 +0200, Hannes Frederic Sowa wrote:
> 
>> This needs to be:
>> 
>> do
>>    ...
>> while ((iskb = iskb->next))
> 
> I do not feel needed to break the bulk dequeue at precise quota
> boundary. These quotas are advisory, and bql prefers to get its full
> budget for appropriate feedback from TX completion.
> 
> Quota was a packet quota, which was quite irrelevant if segmentation had
> to be done, so I would just let the dequeue be done so that we benefit
> from optimal xmit_more.

Yes, this makes sense, do a full qdisc_restart() cycle without boundaries,
then check how much quota was used afterwards to guard the outermost loop.
