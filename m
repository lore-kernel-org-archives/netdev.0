From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 12:28:41 +0200
Message-ID: <20150430102841.GA3373@salvia>
References: <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <20150430003740.GF7025@acer.localdomain>
 <55417F80.4000506@iogearbox.net>
 <20150430014316.GB7956@acer.localdomain>
 <554194E9.5040002@mojatatu.com>
 <20150430032921.GB8950@acer.localdomain>
 <20150430040535.GH8950@acer.localdomain>
 <20150430060256.GA12790@Alexeis-MBP.westell.com>
 <5541F4E9.8080009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59849 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbbD3KYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 06:24:08 -0400
Content-Disposition: inline
In-Reply-To: <5541F4E9.8080009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 11:24:57AM +0200, Daniel Borkmann wrote:
> On 04/30/2015 08:02 AM, Alexei Starovoitov wrote:
> ...
> >My point is that I agree that cleanup of ingress qdisc is needed.
> >I disagree with drastic measures.
> >Just add your nf_hook to ingress and let's see how things evolve.
> >We have rx_handler and all of ptype hooks in there. One can argue
> >that rx_handler overlaps with nf_hook too ? ;)
> >We cannot generalize them all under one 'hook' infra.
> >nf needs to do nf_hook_state_init() and pass it around which
> >no one else needs. That's the cost others should not pay.
> 
> +1

Actually, the state object can be useful to resolve the major bug in
actions that mangle skbs in an illegal way, as we can use it to pass
back to the ingress path the new skb_shared_check()'ed skb.

The genericity that they state object introduces comes with a cost, no
doubt, but it helps to extend things later on and resolve tricky
situation like the one above without large patches to propagate new
state information that you need all over the code.

Regarding the performance argument that is repeating over and over
again, we all here are quite aware here that there's is a *good room
for improvement* in qdisc ingress itself...
