From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Fri, 29 Jan 2016 19:35:20 -0800 (PST)
Message-ID: <20160129.193520.477355610549821770.davem@davemloft.net>
References: <20160129180651.GA17127@oracle.com>
	<20160130024556.6227.51798.stgit@localhost.localdomain>
	<1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, sowmini.varadhan@oracle.com,
	tom@herbertland.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbcA3DfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 22:35:24 -0500
In-Reply-To: <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2016 19:23:54 -0800

> On Fri, 2016-01-29 at 18:49 -0800, Alexander Duyck wrote:
>> This patch fixes an issue with unaligned accesses when using
>> eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
>> The fact is when trying to check the length we don't need to be looking at
>> the flow label so we can reorder the checks to first check if we are
>> supposed to gather the flow label and then make the call to actually get
>> it.
>> 
>> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
> 
> 
> You did not quite follow the discussion Alexander, we did not exactly
> took a decision about this bug.
> 
> As we mentioned, there are other parts that need care.
> 
> key_keyid->keyid = *keyid;
> 
> Please address them, instead of having to 'wait' for the next crash.

Indeed, this is a more fundamental issue.

This change in and of itself isn't bad, and is probably a suitable
micro-optimization for net-next, but it doesn't fix the bug in
question.
