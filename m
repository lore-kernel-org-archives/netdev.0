From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 04 May 2015 14:47:32 -0400
Message-ID: <5547BEC4.4090400@mojatatu.com>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org> <20150504155639.GA14367@Alexeis-MBP.westell.com> <20150504161956.GK22481@breakpoint.cc> <5547AA9C.3030300@mojatatu.com> <20150504174358.GN22481@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150504174358.GN22481@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/04/15 13:43, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>> It is an either-or choice. You cant have both.
>
> Again, why is there a need to have both (at same time)?
>

Pick your favorite distro. Do you seriously believe my tc scripts
will work by default as they used to when the distro ships
with iptables turned on? Get a freshly minted distro
and try to check what the defaults are.
I have no idea what some of these things are for but they
are there.

>> The _evil genius_ part i
>
> Please don't accuse anyone of being 'evil'.
>

It is a figure of speech and was intended to be humorous.
I consider Pablo a friend, sorry if that came out wrong.

> I think that tc and netfilter are both broken by design in the sense
> that we have two different systems with partially overlapping
> functionality while interaction between them consists of hacks.
>
> It works both ways, iptables CLASSIFY target is also not very
> elegant from a design point of view, it bolts the packet/connection matching
> functionality provided by iptables to qdisc hierarchy.
>

Well, from the tc perspective the angle has been one of laziness
and avoiding to rewrite any features that netfilter has. Essentially
a gateway-to-iptables. It has not been easy.
It does look silly if we copy things netfilter does in our view.

>> think is that distros which ship with iptables rules and conntracking
>> on are going to not even turn on tc and my scripts now have to go
>> unload one.
>
> You mean add 'rmmod nft_ingress' or something similar?
>
> That might be a problem.  One possible way out would be to
> make 'tc qdisc add dev eth0 ingress' silently unregister nft ingress
> on kernel side (but not vice versa).
>
> Not nice, but it would keep compatibility with tc ingress scripts.
>

Assuming there is something else using the nft side, now they break
because tc has taken over.

>> But even if the scripts worked (perhaps there are plans to make sure
>> all scripts continue to work transparently), i care about performance
>> and  youve suddenly taken that away from me.
>
> I don't think thats an unsolveable problem, currently we have the
> qdisc->enqueue() indirection, now we have hook + qdisc->enqueue() BUT
> AFAIU the latter could now be avoided by having ingress hook
> interact with sch_ingress directly.
>
> That being said, I am not opposed to two hooks, I just don't see any
> technical reason whatsoever why one would need two different ingress
> classification engines in use at same time.
>

What i described above.

cheers,
jamal
