From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 08:12:18 -0700
Message-ID: <552D2E52.8020303@intel.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <20150410132205.GF23070@casper.infradead.org> <20150410200901.GB5968@salvia> <20150412.211421.1771298417488412635.davem@davemloft.net> <20150413201913.GD20275@acer.localdomain> <552D07C4.1020509@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <552D07C4.1020509@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2015 05:27 AM, Jamal Hadi Salim wrote:
> On 04/13/15 16:19, Patrick McHardy wrote:
> 
>> I'm going to jump in here since I think a good case for this can be
>> made. It's going to be a bit longer, sorry. You can skip to the
>> examples after the first three paragraphs since it's just a lot of
>> TC bashing :)
> 
> Patrick, maybe i am misunderstanding.
> Here I am arguing against Alexei for introducing a couple of
> statements for the sake of performance and you want to put netfilter
> on that code path and maybe move ingress to be dependent on netfilter
> further up the stack? I know you are trying to sell the virtues
> of nft but since you are busy bashing here, how about this polite
> statement:
> Netfilter is not known for its performance. Even with the ingress qlock
> tc will outperform an equivalent operation done via netfilter.

avoiding the nft vs tc vs ebpf debate I will the ingress qlock is not
needed anymore I just haven't got to removing it yet. Its not actually
protecting any data structures though.

I was hoping to push the skb lists onto something like rte_ring
used by the DPDK folks or possibly some of the lockless ring work Jesper
created. This is needed for many qdisc's to drop the qlock but not the
ingress qdisc. Been busy working on switch bits lately but might be
able to pick this up next merge window.

Thanks,
John
