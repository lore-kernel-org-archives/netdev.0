From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: Remove some spurious dropped packet profile
 hits from the passive connection accept path
Date: Thu, 20 Nov 2014 13:31:27 -0800
Message-ID: <546E5DAF.5090907@hp.com>
References: <20141120185829.986CB290095D@tardy> <1416516423.8629.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:45837 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758182AbaKTVb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 16:31:28 -0500
In-Reply-To: <1416516423.8629.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2014 12:47 PM, Eric Dumazet wrote:
> On Thu, 2014-11-20 at 10:58 -0800, Rick Jones wrote:
>> From: Rick Jones <rick.jones2@hp.com>
>>
>> When a system is the passive accepter of many connections, for example
>> when the target of a netperf TCP_CC or TCP_CRR test, or as say a web
>> server, the discard of the skb containing the TCP SYN being processed
>> for the LISTEN endpoint should be a consume_skb() rather than a kfree_skb()
>> to avoid cluttering a dropped packet profile.
>>
>> Signed-off-by: Rick Jones <rick.jones2@hp.com>
>>
>> ---
>
> So what happens if we really drop the packet ?

Do you mean when there is actually data in the SYN?

rick

>
> TCP stack at this point owns the packet, it is possible to mark a bit in
> it to either call consume_skb() or kfree_skb()
>
> I attempted this once but gave up because it was a quite intrusive
> patch...
