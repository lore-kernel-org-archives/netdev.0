From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 04 May 2015 13:21:32 -0400
Message-ID: <5547AA9C.3030300@mojatatu.com>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org> <20150504155639.GA14367@Alexeis-MBP.westell.com> <20150504161956.GK22481@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Florian Westphal <fw@strlen.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150504161956.GK22481@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/04/15 12:19, Florian Westphal wrote:
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

>> wow, I have to say I'm impressed. That's the most genius way to
>> really kill TC.
>> Patch 1 looks good, patch 2,3,4 are nicely building on top...
>> until somebody starts asking how patch 5 will look.
>> In the future netfilter ingress module will be loaded along with
>> other iptables modules just like conntrack is today and users
>> who would want to use ingress tc would have to _unload_
>> netfilter_ingress module, but if it has interesting dependencies
>> it may mean to unload iptables and the rest.
>
> FWIW while I think this is a valid concern, I believe its unfounded.
>
> netfilter_ingress must not force run-time
> dependencies like 'oh, you want tc, too bad, no conntrack for you)'.
>
> (and i don't see any need for such a dependency).
>

It is an either-or choice. You cant have both. The _evil genius_ part i
think is that distros which ship with iptables rules and conntracking
on are going to not even turn on tc and my scripts now have to go
unload one.
But even if the scripts worked (perhaps there are plans to make sure
all scripts continue to work transparently), i care about performance
and  youve suddenly taken that away from me.

So i would agree with adding the two hooks. Priority should be given
to tc in the code path.

cheers,
jamal
