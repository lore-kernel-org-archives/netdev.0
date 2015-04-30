From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 02:37:41 +0200
Message-ID: <20150430003740.GF7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150429233205.GA3416@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.04, Pablo Neira Ayuso wrote:
> On the bugfix front, the illegal mangling of shared skb from actions
> like stateless nat and bpf look also important to be addressed to me.
> David already suggested to propagate some state object that keeps a
> pointer to the skb that is passed to the action. Thus, the action can
> clone it and get the skb back to the ingress path. I started a
> patchset to do so here, it's a bit large since it requires quite a lot
> of function signature adjustment.

Jumping in on this point - the fact that roughly 2/3 of TC actions will
simply BUG under not unlikely circumstances when used in ingress (I went
through them one by one with Pablo a week ago) is also telling. Nobody
seems to be using that. All packet mangling actions will BUG while any
tap is active. Its nothing easily fixed, but apparently nobody has cared
in ten years. ipt is trivial to crash differently, connmark is as well.

So I'm wondering what are we actually arguing about here. Whether we are
affecting the performance how fast TC will crash? We *do* actually care
about these thing, in TC apparently nobody has for the past ten years.
