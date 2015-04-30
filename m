From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 02:20:21 +0200
Message-ID: <55417545.30103@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37519 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbbD3AUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 20:20:23 -0400
In-Reply-To: <20150429233205.GA3416@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 01:32 AM, Pablo Neira Ayuso wrote:
...
>> Therefore, I think it would be better to not wrap that ingress qdisc
>> part of the patch set into even more layers. What do you think?
>
> I think the main front to improve performance in qdisc ingress is to
> remove the central spinlock that is harming scalability. There's also
> the built-in rule counters there that look problematic. So I would
> focus on improving performance from the qdisc ingress core
> infrastructure itself.
>
> On the bugfix front, the illegal mangling of shared skb from actions
> like stateless nat and bpf look also important to be addressed to me.
> David already suggested to propagate some state object that keeps a
> pointer to the skb that is passed to the action. Thus, the action can
> clone it and get the skb back to the ingress path. I started a
> patchset to do so here, it's a bit large since it requires quite a lot
> of function signature adjustment.
>
> I can also see there were also intentions to support userspace
> queueing at some point since TC_ACT_QUEUED has been there since the
> beginning.  That should be possible at some point using this
> infrastructure (once there are no further concerns on the
> netif_receive_core_finish() patch as soon as gcc 4.9 and follow up
> versions keep inlining this new function).

Wrt the other mail, just thinking out loud ... do you see a longer-term
possibility of further generalizing the gen hooks infrastructure, so that
actually classifier from tc could attach (disregarding the nf_* naming
scheme for now) ...

     `-> nf_hook_slow()
      `-> [for each entry in hook list]   <-- here as an entry
       `-> nf_iterate()
        `-> (*elemp)->hook()

... as well?

Thanks,
Daniel
