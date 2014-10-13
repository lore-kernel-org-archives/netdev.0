From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH 1/2] netfilter: kill nf_send_reset6() from include/net/netfilter/ipv6/nf_reject.h
Date: Mon, 13 Oct 2014 13:18:06 -0400
Message-ID: <CA+5PVA7HprKjQBDvjximvzfHU5tXuV7ovJHA9n2FE6qF7ZnMag@mail.gmail.com>
References: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
	<1412879261-25045-2-git-send-email-pablo@netfilter.org>
	<CA+5PVA7-k-HFGUUeZ3LTCmVcmR1h_=8W-_PzRO4-2dcc_cRHaQ@mail.gmail.com>
	<20141013155510.GA26105@breakpoint.cc>
	<CA+5PVA72ME31+CAzcM46JyvrP19dawTO4LSmta6Jt2eDZVbWaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA72ME31+CAzcM46JyvrP19dawTO4LSmta6Jt2eDZVbWaA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 13, 2014 at 12:01 PM, Josh Boyer <jwboyer@fedoraproject.org> wrote:
> On Mon, Oct 13, 2014 at 11:55 AM, Florian Westphal <fw@strlen.de> wrote:
>> Josh Boyer <jwboyer@fedoraproject.org> wrote:
>>> On Thu, Oct 9, 2014 at 2:27 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>>> > nf_send_reset6() now resides in net/ipv6/netfilter/nf_reject_ipv6.c
>>> >
>>> > Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to nf_reject_ipvX modules")
>>> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>>> > Acked-by: Eric Dumazet <edumazet@google.com>
>>> > ---
>>> >  include/net/netfilter/ipv6/nf_reject.h |  157 +-------------------------------
>>> >  1 file changed, 2 insertions(+), 155 deletions(-)
>>>
>>> Hi All,
>>>
>>> This morning I was testing a kernel build from Linus' tree as of Linux
>>> v3.17-7639-g90eac7eee2f4.  When I rebooted my test machines, I
>>> couldn't ssh back into any of them.  I poked around a bit and noticed
>>> that it seems the iptables rules weren't getting loaded properly.
>>> Traffic out worked fine, and I could ping the machine, but other
>>> incoming traffic was blocked.  Then I saw that the ip6t_REJECT and
>>> ip6t_rpfilter modules were not being loaded on the bad kernel.
>>> Looking in dmesg I see:
>>>
>>> [   14.619028] nf_reject_ipv6: module license 'unspecified' taints kernel.
>>> [   14.619125] nf_reject_ipv6: Unknown symbol ip6_local_out (err 0)
>>
>> Ouch. ip6_local_is EXPORT_SYMBOL_GPL.
>>
>> http://patchwork.ozlabs.org/patch/398501/
>>
>> should fix this.
>
> I believe you're correct.  I dug in some more and I was just about to
> send a similar patch.  I'll add it on top of my builds and test it
> out.  Thanks for the pointer.

The patch you pointed to does indeed fix the issues I was seeing.
Thank you very much for the fast response.

josh
