From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Tue, 9 Sep 2008 11:32:45 +0400
Message-ID: <20080909073245.GA7307@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C623CA.9060803@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2008 at 09:20:42AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Add checks for init_net to not create kmem caches twice and so on.
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>>
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
>> index b55944e..52d0663 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -1016,7 +1016,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
>>     supposed to kill the mall. */
>>  void nf_conntrack_cleanup(struct net *net)
>>  {
>> -	rcu_assign_pointer(ip_ct_attach, NULL);
>> +	if (net_eq(net, &init_net))
>> +		rcu_assign_pointer(ip_ct_attach, NULL);
>
> Having multiple of these net_eq checks per function (14 total) is
> not a very nice way to do this.

Yep, I was just afraid of some subtle ordering rules and to keep
potential init_net breakage to minimum.

> How about splitting the code into a netns and a global part instead?

Prebably they aren't strict at all.
