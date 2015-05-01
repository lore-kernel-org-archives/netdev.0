From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 21:15:35 -0400
Message-ID: <5542D3B7.1060307@mojatatu.com>
References: <20150429233205.GA3416@salvia> <55417545.30103@iogearbox.net> <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain> <554191F9.3010301@mojatatu.com> <20150430031138.GA8950@acer.localdomain> <5542182A.800@mojatatu.com> <20150430153317.GA3230@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430153317.GA3230@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo,

On 04/30/15 11:33, Pablo Neira Ayuso wrote:

>
> You keep saying that qdisc ingress outperforms, that's only right for
> just a very slight difference when comparing it with no rules on
> single CPU (when ported to the common playground of the generic hook
> infrastructure). On SMP nftables will outperform, even more if the
> ruleset is arranged in a non-linear list fashion, with all the new
> tricks that we got.
>

I am interested to see the numbers. I think this would be a great paper;
it is extremely tempting to spend time on it.

> Anyway, let's take this "nftables vs. qdisc ingress" discussion to an
> end. I think the main point of this discussion is to provide a generic
> entry point to ingress filtering (for both qdisc ingress and nftables)
> that, if unused, doesn't harm performance of the critical path
> netif_receive_core() path at all. Thus, users can choose what they
> want, I have heard you saying several times: "To each their poison"
> and I like that.
>

Yes - but my good friend Patrick is not saying that.
I dont want to turn on netfilter in order to get tc actions on ingress.
And i dont want to be slowed down because now the code path has become
longer. We are trying to prune the code path. If somehow you can work to
not affect performance then we can live well together.

cheers,
jamal
