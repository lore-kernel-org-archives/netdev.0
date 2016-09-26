From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH nf-next 2/2] nf_set_hooks_head: acommodate different kconfig
Date: Mon, 26 Sep 2016 12:43:17 -0400
Message-ID: <f7t4m52lihm.fsf@redhat.com>
References: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
        <1474907071-13591-3-git-send-email-aconole@bytheb.org>
        <20160926163920.GB17426@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160926163920.GB17426@breakpoint.cc> (Florian Westphal's
        message of "Mon, 26 Sep 2016 18:39:20 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> writes:

> Aaron Conole <aconole@bytheb.org> wrote:
>> When CONFIG_NETFILTER_INGRESS is unset (or no), we need to handle
>> the request for registration properly by dropping the hook.  This
>> releases the entry during the set.
>> 
>> Signed-off-by: Aaron Conole <aconole@bytheb.org>
>> ---
>>  net/netfilter/core.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>> 
>> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
>> index e58e420..1d0a4c9 100644
>> --- a/net/netfilter/core.c
>> +++ b/net/netfilter/core.c
>> @@ -90,10 +90,14 @@ static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
>>  {
>>  	switch (reg->pf) {
>>  	case NFPROTO_NETDEV:
>> +#ifdef CONFIG_NETFILTER_INGRESS
>>  		/* We already checked in nf_register_net_hook() that this is
>>  		 * used from ingress.
>>  		 */
>>  		rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
>> +#else
>> +		kfree(entry);
>> +#endif
>>  		break;
>
> This looks dodgy (its correct though).
>
> I'd propose to add a test to nf_register_net_hook()
> to bail with -EOPNOSTUPP instead of this "#else kfree()" if we get
> NFPROTO_NETDEV pf with CONFIG_NETFILTER_INGRESS=n build instead.

Okay, I'll spin a new version.

Thanks for the review, Florian!

-Aaron
