From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Thu, 29 Oct 2009 17:32:22 +0100
Message-ID: <4AE9C396.3040705@nets.rwth-aachen.de>
References: <4AE72075.4070702@simula.no> <4AE7B5D6.8070001@gmail.com>
 <38EB8C31-A96A-4C5C-88D8-8F6BF0E9225F@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54271 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753620AbZJ2Qck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 12:32:40 -0400
In-reply-to: <38EB8C31-A96A-4C5C-88D8-8F6BF0E9225F@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Petlund schrieb:
> Den 28. okt. 2009 kl. 04.09 skrev William Allen Simpson:
> 
>> Andreas Petlund wrote:
>>> +/* Determines whether this is a thin stream (which may suffer from
>>> + * increased latency). Used to trigger latency-reducing mechanisms.
>>> + */
>>> +static inline unsigned int tcp_stream_is_thin(const struct  
>>> tcp_sock *tp)
>>> +{
>>> +	return tp->packets_out < 4;
>>> +}
>>> +
>> This bothers me a bit.  Having just looked at your Linux presentation,
>> and not (yet) read your papers, it seems much of your justification  
>> was
>> with 1 packet per RTT.  Here, you seem to be concentrating on 4,  
>> probably
>> because many implementations quickly ramp up to 4.
>>
> 
> The limit of 4 packets in flight is based on the fact that less than 4  
> packets in flight makes fast retransmissions impossible, thus limiting  
> the retransmit options to timeout-retransmissions. The criterion is  

There is Limited Transmit! So this is generally not true.

> therefore as conservative as possible while still serving its purpose.  
> If further losses occur, the exponential backoff will increase latency  
> further. The concept of using this limit is also discussed in the  
> Internet draft for Early Retransmit by Allman et al.:
> http://www.icir.org/mallman/papers/draft-ietf-tcpm-early-rexmt-01.txt

This ID is covering exactly the cases which Limited Transmit does not
cover and works "automagically" without help of application. So why not
just implement this ID?

Best regards,
Arnd
