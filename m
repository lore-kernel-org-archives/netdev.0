From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 11:55:30 -0800 (PST)
Message-ID: <20110126.115530.226756606.davem@davemloft.net>
References: <1296062517.2899.86.camel@edumazet-laptop>
	<1296063823.6115.37.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753248Ab1AZTyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 14:54:55 -0500
In-Reply-To: <1296063823.6115.37.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 26 Jan 2011 09:43:43 -0800

> On Wed, 2011-01-26 at 18:21 +0100, Eric Dumazet wrote:
>> mqprio_dump() should make sure all fields of struct tc_mqprio_qopt are
>> initialized.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  net/sched/sch_mqprio.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
>> index fbc6f53..effd4ee 100644
>> --- a/net/sched/sch_mqprio.c
>> +++ b/net/sched/sch_mqprio.c
>> @@ -215,7 +215,7 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
>>  	struct net_device *dev = qdisc_dev(sch);
>>  	struct mqprio_sched *priv = qdisc_priv(sch);
>>  	unsigned char *b = skb_tail_pointer(skb);
>> -	struct tc_mqprio_qopt opt;
>> +	struct tc_mqprio_qopt opt = { 0 };
> 
> I think the best style to use memset so that any
> possible struct padding is guaranteed to be zeroed.

Such padding does not exist, and we won't add such padding since this is
a user visible data structure and thus whose layout is cast in stone.

Anyways, I'm ambivalent to how this is fixed actually.
