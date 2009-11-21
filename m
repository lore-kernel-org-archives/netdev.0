From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Sat, 21 Nov 2009 01:40:11 +0100
Message-ID: <4B0736EB.8090406@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120.153913.242783116.davem@davemloft.net>	 <65634d660911201550v34bc463ao17dcd7b16f62264f@mail.gmail.com>	 <20091120.160507.110482370.davem@davemloft.net> <65634d660911201612y12a9b5bnb6685da040ad832d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:53531 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbZKUAkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 19:40:32 -0500
Received: by bwz27 with SMTP id 27so3856080bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 16:40:37 -0800 (PST)
In-Reply-To: <65634d660911201612y12a9b5bnb6685da040ad832d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote, On 11/21/2009 01:12 AM:

>> I guess my confusion is from the:
>>
>>                                __raise_softirq_irqoff(NET_RX_SOFTIRQ);
>>
>> you are doing as you set the cpus in rps_remote_softirq_cpus.
>>
>> Why do you need to schedule the local RX softirq, when we know we're
>> in a NAPI poll loop and thus that we're in a softirq, and thus that we
>> will fire off the IPIs at the end of net_rx_action()?
>>
>> That's what you're doing, the softirq raising just seems superfluous.
>>
> 
> Ah, right. If RPS can't be used non-NAPI case, this line is now
> superfluous.  It can be removed.

Hmm... mostly right. At least if it's wrt. my previous opinion. I meant
only that non-NAPI case would be handled less optimally without this
dedicated softirq, but __raise_softirq_irqoff(NET_RX_SOFTIRQ) or
napi_schedule(&queue->backlog) could be called from netif_rx().

Jarek P.
