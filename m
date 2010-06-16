From: Arturas <arturasl@res.lt>
Subject: Re: BUG: unable to handle kernel paging request at 000041ed00000001
Date: Wed, 16 Jun 2010 13:25:24 +0300
Message-ID: <20890DF2-B0EA-4C80-A64C-83F44E95DD6E@res.lt>
References: <9D7251E7-0EFD-4645-BC30-A96191D1046E@res.lt> <1276185609.2448.12.camel@edumazet-laptop> <80C864F3-B075-4E3A-B72E-6FCD945A8058@res.lt> <1276504295.2478.35.camel@edumazet-laptop> <96E62960-9EF8-4F05-92DD-2D7477D0D78B@res.lt>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.res.lt ([84.32.72.39]:56760 "EHLO mx.res.lt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051Ab0FPKZ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 06:25:27 -0400
In-Reply-To: <96E62960-9EF8-4F05-92DD-2D7477D0D78B@res.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Your new patch doesn't show any warnings about tx queue 
and everything is working as expected.

On Jun 14, 2010, at 12:27 PM, Arturas wrote:

> 
> On Jun 14, 2010, at 11:31 AM, Eric Dumazet wrote:
>> But your problem is about bridge, not bonding (see trace).
> I want it for performance reason, not because of this bug.
> Bridge isn't a bottleneck for me, but bonding may be and not to me only,
> but for many people. I believe that performance gain would be more 
> than 1% on cpu? :-)
> 
>> 
>> And 2.6.34 wont accept such changes, its already released.
> It can be as a separate patch or I can test 2.3.35 if it would accept
> such change. I just need a stable kernel with good performance :-)
> 
>> 
>>> I also have another issue with NMI. On older machine with 5500 xeons i 
>>> have almost no overhead with nmi_watchdog enabled, but on this it is about twice.
>>> without nmi enabled cpu peak average is 30%, and with nmi enabled i have 53%.
>>> When traffic is not passing all cpus are idling at 100%.
>>> Maybe overhead could be a little bit smaller? :-)
>>> 
>> 
>> I am a bit lost here, NMI have litle to do with network stack ;)
> May this be related to very recent cpu? As i understand NMI depends on CPU.
> 
>> 
>> 
>> Could you please test another patch ?
> Applied, it's working correctly for now. If i'll get a warning i'll write you or maybe I
> shouldn't get it if a patch is correct?
> 
>> 
>> Before calling sk_tx_queue_set(sk, queue_index); we should check if dst
>> dev is current device.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

