From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Wed, 01 Oct 2008 12:10:10 +0200
Message-ID: <48E34C82.2040306@fr.ibm.com>
References: <20080930144203.GA2511@ami.dom.local> <20080930145710.GB2511@ami.dom.local> <48E24341.5050609@bull.net> <20081001.025935.257260146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:47827 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022AbYJAKKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:10:51 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m91AADGg072332
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 10:10:13 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91AADuU4141256
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 12:10:13 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91AACSI003901
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 12:10:12 +0200
In-Reply-To: <20081001.025935.257260146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Benjamin Thery <benjamin.thery@bull.net>
> Date: Tue, 30 Sep 2008 17:18:25 +0200
> 
>> Jarek Poplawski wrote:
>>> On Tue, Sep 30, 2008 at 04:42:04PM +0200, Jarek Poplawski wrote:
>>>> Benjamin Thery wrote, On 09/30/2008 01:52 PM:
>>> ...
>>>>> I'm still looking at why the first dst_free() on those particular routes doesn't call dst_destroy() immediately but defers it (another refcount
>>>>> on the route itself).
>>>> Yes, finding/fixing this, if possible, in this place looks like the
>>>> most consistent with the way netdev_wait_allrefs() is handling this.
>>> Actually, I wonder, why we can't simply run this dst_gc_task() from
>>> dst_dev_event() (after cancelling the work) when needed.
>>>
>> Um... I haven't thought about this. I'll have a look to see if it can
>> solve our issue.
> 
> Let me know what happens, I'd like to apply some fix soon.
> So just report the patch implementing the final approach you
> feel the most comfortable with.

We did the modification suggested by Jarek and that fix the problem :)
We are playing a bit with this patch to check if we didn't missed 
something. We will certainly send it in the next hours.

Thanks.

