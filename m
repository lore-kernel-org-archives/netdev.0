From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] netfilter: nf_queue: Don't recompute the hook_list head
Date: Sat, 20 Jun 2015 09:08:20 -0500
Message-ID: <877fqya2wb.fsf@x220.int.ebiederm.org>
References: <87381ne3rq.fsf@x220.int.ebiederm.org>
	<20150620105839.GB3439@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150620105839.GB3439@salvia> (Pablo Neira Ayuso's message of
	"Sat, 20 Jun 2015 12:58:39 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Fri, Jun 19, 2015 at 05:23:37PM -0500, Eric W. Biederman wrote:
>> 
>> If someone sends packets from one of the netdevice ingress hooks to
>> the a userspace queue, and then userspace later accepts the packet,
>> the netfilter code can enter an infinite loop as the list head will
>> never be found.
>> 
>> Pass in the saved list_head to avoid this.
>
> There is no userspace queueing for netdevice yet, so this can be route
> through nf-next. Thanks.

*scratches head* the netdevice queueing is in the netfilter core.

netfilter_ingress calls nf_hook_slow.  The queuing happens in
nf_hook_slow if anything returns the verdict queue it.

This patch applies to Linus's tree.

So how in the world does this not need to be ported to 4.1?

>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  net/netfilter/nf_queue.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
>> index cd60d397fe05..8a8b2abc35ff 100644
>> --- a/net/netfilter/nf_queue.c
>> +++ b/net/netfilter/nf_queue.c
>> @@ -213,7 +213,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
>>  
>>  	if (verdict == NF_ACCEPT) {
>>  	next_hook:
>> -		verdict = nf_iterate(&nf_hooks[entry->state.pf][entry->state.hook],
>> +		verdict = nf_iterate(entry->state.hook_list,
>>  				     skb, &entry->state, &elem);
>>  	}
>>  
>> -- 
>> 2.2.1
>> 
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
