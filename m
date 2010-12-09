From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: ctnetlink loop
Date: Thu, 09 Dec 2010 11:39:56 +0100
Message-ID: <4D00B1FC.60801@netfilter.org>
References: <20101208.095020.245408999.davem@davemloft.net> <20101208203121.GB23668@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101208203121.GB23668@mail.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/10 21:31, Holger Eitzenberger wrote:
> Hi,
> 
>> Holger, this replay -EAGAIN loop in nfnetlink processing was added by
>> Pablo to handle module loading properly, I think.  So it might not be
>> safe to just unilaterally remove it.
> 
> thanks for your reply!
> 
> Pablo, do we really need the replay loop really?

Yes, we need it for the on-demand module loading.

> I now have several
> boxes with problems due to this replay.  'perf report' always gives me
> something like:
> 
>       18.88%            ulogd  [kernel]
>   [k] __nla_put
>       10.73%            ulogd  [kernel]
>   [k] nla_parse
>        8.72%            ulogd  [kernel]
>   [k] __nla_reserve
>        6.64%            ulogd  [kernel]
>   [k] nla_put
>        5.14%            ulogd  [kernel]
>   [k] validate_nla
>        5.03%            ulogd  [kernel]
>   [k] pskb_expand_head
>        4.92%            ulogd  [kernel]
>   [k] ctnetlink_fill_info [nf_conntrack_netlink]
>        3.07%            ulogd  [kernel]
>   [k] skb_put
>        3.03%            ulogd  [kernel]
>   [k] ctnetlink_dump_counters [nf_conntrack
> 
> And 'strace' shows me that ulogd is stuck in its 'select' call.

Sorry, I missed your previous emails. Why do you think that this related
to -EAGAIN in nfnetlink?
