From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 18:09:25 +0200
Message-ID: <554253B5.40801@iogearbox.net>
References: <20150429233205.GA3416@salvia> <55417545.30103@iogearbox.net> <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain> <554191F9.3010301@mojatatu.com> <20150430031138.GA8950@acer.localdomain> <5542182A.800@mojatatu.com> <20150430153317.GA3230@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48276 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbbD3QJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:09:30 -0400
In-Reply-To: <20150430153317.GA3230@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 05:33 PM, Pablo Neira Ayuso wrote:
...
> On Thu, Apr 30, 2015 at 07:55:22AM -0400, Jamal Hadi Salim wrote:
> [...]
>> Start with a zero rules. Add them logarithmically (with and without
>> traffic running). i.e in order of {0, 1, 10, 100, 1000, ...}
>> With a single rule you dont notice much difference. Start adding rules
>> and it becomes very obvious.
>
> I think the days of linear ruleset performance competitions are over,

Totally agree with you. You want to have a single classification pass
that parses the packet once and comes to a verdict immediately.

> we have better data structures to allow users to arrange the ruleset
> through the multidimensional dictionaries and the arbitrary state
> flows that minimize the number of inspections, which is what it harms
> performance when it comes to packet classification.

I think both have different use cases, though, but on cls_bpf side you
have maps infrastructure that is evolving as well. Not really speaking
about the other remaining classifiers, however. I also don't want to go
any further into this vim vs emacs debate. ;) And, personally, I also
don't have any issue offering alternatives to users.

However, I still disagree with moving ingress behind this artificial
barrier if it's just not necessary. I believe, in your RFC v1 patch,
you had a second ingress hook as a static key for nft, I tend to like
that much better consensus-wise. Both subsystems should not put
unnecessary barriers into their way, really.

Best,
Daniel
