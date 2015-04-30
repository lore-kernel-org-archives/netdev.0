From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 21:16:17 +0200
Message-ID: <55427F81.4080807@iogearbox.net>
References: <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain> <554191F9.3010301@mojatatu.com> <20150430031138.GA8950@acer.localdomain> <5542182A.800@mojatatu.com> <20150430153317.GA3230@salvia> <554253B5.40801@iogearbox.net> <20150430163634.GA3814@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430163634.GA3814@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/30/2015 06:36 PM, Pablo Neira Ayuso wrote:
...
> But where are the barriers? These unfounded performance claims are
> simply absurd, qdisc ingress barely performs a bit better just because
> it executes a bit less code and only in the single CPU scenario with
> no rules at all.

I think we're going in circles a bit. :( You are right in saying that
currently, there's a central spinlock, which is worked on to get rid
of, you've seen the patch on the list floating around already. Single
CPU, artificial micro-benchmark, which were done show that you see on
your machine ~613Kpps to ~545Kpps, others have seen it more amplified
as 22.4Mpps to 18.0Mpps drop from __netif_receive_skb_core() up to an
empty dummy u32_classify() rule, which has already been acknowledged
that this gap needs to be improved. Lets call it unfounded then. I
think we wouldn't even have this discussion if we wouldn't try brute
forcing both worlds behind this single static key, or, have both
invoked from within the same layer/list.

Cheers,
Daniel
