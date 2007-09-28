From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] Make TCP prequeue configurable
Date: Thu, 27 Sep 2007 22:26:02 -0400
Message-ID: <46FC663A.6030601@psc.edu>
References: <46FC29E1.9010809@cosmosbay.com> <20070927154432.6ca3b525@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53258 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909AbXI1C1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 22:27:22 -0400
In-Reply-To: <20070927154432.6ca3b525@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 28 Sep 2007 00:08:33 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
>> Hi all
>>
>> I am sure some of you are going to tell me that prequeue is not
>> all black :)
>>
>> Thank you
>>
>> [RFC] Make TCP prequeue configurable
>>
>> The TCP prequeue thing is based on old facts, and has drawbacks.
>>
>> 1) It adds 48 bytes per 'struct tcp_sock'
>> 2) It adds some ugly code in hot paths
>> 3) It has a small hit ratio on typical servers using many sockets
>> 4) It may have a high hit ratio on UP machines running one process,
>>     where the prequeue adds litle gain. (In fact, letting the user
>>     doing the copy after being woke up is better for cache reuse)
>> 5) Doing a copy to user in softirq handler is not good, because of
>>     potential page faults :(
>> 6) Maybe the NET_DMA thing is the only thing that might need prequeue.
>>
>> This patch introduces a CONFIG_TCP_PREQUEUE, automatically selected if 
>> CONFIG_NET_DMA is on.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
> 
> Rather than having a two more compile cases and test cases to deal
> with.  If you can prove it is useless, make a case for killing
> it completely.


I think it really does help in case (4) with old NICs that don't do rx 
checksumming.  I'm not sure how many people really care about this 
anymore, but probably some...?

OTOH, it would be nice to get rid of sysctl_tcp_low_latency.

   -John
