From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Fri, 24 Aug 2012 13:42:31 -0400 (EDT)
Message-ID: <20120824.134231.41073001349178209.davem@davemloft.net>
References: <1345724123.5904.756.camel@edumazet-glaptop>
	<50362407.9070805@linlab.net>
	<1345726185.5904.835.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@linlab.net, hkjerry.chu@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757287Ab2HXRmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:42:33 -0400
In-Reply-To: <1345726185.5904.835.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Aug 2012 14:49:45 +0200

> On Thu, 2012-08-23 at 14:37 +0200, Alex Bergmann wrote:
> 
>> 
>> From be551f82499112e4775b6d579d58967510b6d492 Mon Sep 17 00:00:00 2001
>> From: Alexander Bergmann <alex@linlab.net>
>> Date: Thu, 23 Aug 2012 14:33:35 +0200
>> Subject: [PATCH 1/1] tcp: Increase timeout for SYN segments
>> 
>> Commit 9ad7c049 changed the initRTO from 3secs to 1sec in accordance to
>> RFC6298 (former RFC2988bis). This reduced the time till the last SYN
>> retransmission packet gets sent from 93secs to 31secs.
>> 
>> RFC1122 is stating that the retransmission should be done for at least 3
>> minutes, but this seems to be quite high.[1]
>> 
>> This patch increases the value of TCP_SYN_RETRIES to the value of 6,
>> providing a retransmission window of 63secs.
>> 
>> [1] RFC 1122 - 4.2.3.5 TCP Connection Failures
>> 
>> Signed-off-by: Alexander Bergmann <alex@linlab.net>
>> ---
>>  include/net/tcp.h |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 1f000ff..f309e93 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -98,7 +98,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
>>                                  * 15 is ~13-30min depending on RTO.
>>                                  */
>>  
>> -#define TCP_SYN_RETRIES         5      /* number of times to retry active opening a
>> +#define TCP_SYN_RETRIES         6      /* number of times to retry active opening a
>>                                  * connection: ~180sec is RFC minimum   */
>>  
>>  #define TCP_SYNACK_RETRIES 5   /* number of times to retry passive opening a
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> A change of the comment might be good, to help future readers.

Alex, this patch doesn't apply, it was completely corrupted by your email
client.

Make a fresh submission, with this fixed.  But before you do, email the
patch to yourself and make sure you can actually apply the patch you
receive in your inbox.  Because that's exactly what I'm going to have
to do.

Thanks.
