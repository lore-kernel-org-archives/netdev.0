From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] netfilter: nf_conntrack: Use net_mutex for helper unregistration.
Date: Mon, 16 May 2016 21:38:53 -0700
Message-ID: <CAPWQB7Eqoxk6-B5iEhkk9yF-DDduavtm=K8OE-3Of7JF6-Opvg@mail.gmail.com>
References: <1462488637-46877-1-git-send-email-joe@ovn.org> <20160506110325.GA2420@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160506110325.GA2420@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6 May 2016 at 04:03, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> Hi Joe,
>
> On Thu, May 05, 2016 at 03:50:37PM -0700, Joe Stringer wrote:
>> diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
>> index 3b40ec575cd5..6860b19be406 100644
>> --- a/net/netfilter/nf_conntrack_helper.c
>> +++ b/net/netfilter/nf_conntrack_helper.c
>> @@ -449,10 +449,10 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
>>        */
>>       synchronize_rcu();
>>
>> -     rtnl_lock();
>> +     mutex_lock(&net_mutex);
>>       for_each_net(net)
>>               __nf_conntrack_helper_unregister(me, net);
>> -     rtnl_unlock();
>> +     mutex_unlock(&net_mutex);
>
> This simple solution works because we have no .exit callbacks in any
> of our helpers. Otherwise, the helper code may be already gone by when
> the worker has a chance to run to release the netns.
>
> If so, probably I can append this as comment to this function so we
> don't forget. If we ever have .exit callbacks (I don't expect so), we
> would need to wait for worker completion.

Hi Pablo,

Did you want me to re-spin this patch or look into another approach?
