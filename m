From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add tipc support
Date: Mon, 26 Jan 2015 16:57:49 -0800 (PST)
Message-ID: <20150126.165749.913857343835846078.davem@davemloft.net>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
	<1421943032-29924-2-git-send-email-erik.hugne@ericsson.com>
	<1421947751.3471.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: erik.hugne@ericsson.com, richard.alpe@ericsson.com,
	netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbbA0A5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:57:51 -0500
In-Reply-To: <1421947751.3471.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Jan 2015 09:29:11 -0800

> On Thu, 2015-01-22 at 17:10 +0100, erik.hugne@ericsson.com wrote:
>> From: Erik Hugne <erik.hugne@ericsson.com>
>> 
>> The flows are hashed on the sending node address, which allows us
>> to spread out the TIPC link processing to RPS enabled cores. There
>> is no point to include the destination address in the hash as that
>> will always be the same for all inbound links. We have experimented
>> with a 3-tuple hash over [srcnode, sport, dport], but this showed to
>> give slightly lower performance because of increased lock contention
>> when the same link was handled by multiple cores.
>> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
>> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>> ---
>>  net/core/flow_dissector.c | 14 ++++++++++++++
>>  1 file changed, 14 insertions(+)
>> 
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 4508493..beb83d1 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -178,6 +178,20 @@ ipv6:
>>  			return false;
>>  		}
>>  	}
>> +	case htons(ETH_P_TIPC): {
>> +		struct {
>> +			__be32 pre[3];
>> +			__be32 srcnode;
>> +		} *hdr, _hdr;
> 
> Is this header defined somewhere in an include file ?
> 
> This looks a bit ugly to locally define the format...

I'd like this situation improved but I plan to apply this as-is for
now.
