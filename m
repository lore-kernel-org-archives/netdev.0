From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net_sched: gred: actually perform idling in WRED
 mode
Date: Thu, 13 Sep 2012 16:10:45 -0400 (EDT)
Message-ID: <20120913.161045.1221816565860113321.davem@davemloft.net>
References: <1347549755-19438-4-git-send-email-david.ward@ll.mit.edu>
	<50522106.40404@mojatatu.com>
	<50523632.60703@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, brosler@cisco.com,
	cyril@ti.com
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab2IMUKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:10:46 -0400
In-Reply-To: <50523632.60703@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Date: Thu, 13 Sep 2012 15:38:26 -0400

> On 13/09/12 14:08, Jamal Hadi Salim wrote:
>> On 12-09-13 11:22 AM, David Ward wrote:
>>> gred_dequeue() and gred_drop() do not seem to get called when the
>>> queue is empty, meaning that we never start idling while in WRED
>>> mode. And since qidlestart is not stored by gred_store_wred_set(),
>>> we would never stop idling while in WRED mode if we ever started.
>>> This messes up the average queue size calculation that influences
>>> packet marking/dropping behavior.
>>>
>>> Now, we start WRED mode idling as we are removing the last packet
>>> from the queue. Also we now actually stop WRED mode idling when we
>>> are enqueuing a packet.
>>>
>>> Cc: Bruce Osler <brosler@cisco.com>
>>> Signed-off-by: David Ward <david.ward@ll.mit.edu>
>> This is one is not so obvious. Iam assuming you vetted it via some
>> tests.
>> In which case:
>> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> cheers,
>> jamal
>>
> 
> Before applying this patch, the average queue size (as seen with "tc
> -s qdisc") remained constant forever after I stopped sending any
> packets through the interface -- it didn't taper off as you would
> expect.  After the patch, the average queue size will now taper off if
> packets are not being sent.

Applied.
