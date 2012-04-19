From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Thu, 19 Apr 2012 10:20:21 -0700
Message-ID: <4F904955.7070403@hp.com>
References: <1334653608.6226.11.camel@edumazet-laptop> <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com> <1334681204.2472.41.camel@edumazet-glaptop> <1334698722.2472.71.camel@edumazet-glaptop> <1334764184.2472.299.camel@edumazet-glaptop> <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com> <1334776707.2472.316.camel@edumazet-glaptop> <1334778707.2472.333.camel@edumazet-glaptop> <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi> <1334835018.2395.66.camel@edumazet-glaptop> <1334841481.2395.175.camel@edumazet-glaptop> <1334843527.2395.182.camel@edumazet-glaptop> <1334844652.2395.187.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:7164 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562Ab2DSR3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:29:00 -0400
In-Reply-To: <1334844652.2395.187.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2012 07:10 AM, Eric Dumazet wrote:
> On Thu, 2012-04-19 at 15:52 +0200, Eric Dumazet wrote:
>
>> And disabling GRO on receiver definitely demonstrates the problem, even
>> with a single flow. (and performance drops from 9410 Mbit to 6050 Mbit)
>
> That insane.
>
> Performance drops so much because we _drop_ incoming ACKS :
>
> <      TCPSackShifted: 39117
> <      TCPSackMerged: 16500
> <      TCPSackShiftFallback: 5092
> <      TCPBacklogDrop: 27965
> ---
>>      TCPSackShifted: 35122
>>      TCPSackMerged: 16368
>>      TCPSackShiftFallback: 4889
>>      TCPBacklogDrop: 23247
>
> Hmm, maybe we should reduce skb->truesize for small packets before
> queueing them in socket backlog...

By copying them to smaller buffers? Or just by altering truesize? 
Wasn't the whole point of fixing all the broken truesize settings to 
accurately account for memory consumed?

rick
