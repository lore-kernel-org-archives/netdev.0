From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Sun, 30 Nov 2014 16:11:14 +0100
Message-ID: <20141130151114.GA4462@breakpoint.cc>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <20141130102640.GA19726@breakpoint.cc>
 <5A90DA2E42F8AE43BC4A093BF0678848DED957@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Du, Fan" <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56794 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752701AbaK3PLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 10:11:19 -0500
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848DED957@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Du, Fan <fan.du@intel.com> wrote:
> All interface MTU in the test scenario is the default one, 1500.

Not really, unless I misunderstand the setup.

You have a l2 network where part of the machines are connected by a
l2 tunnel.

All machines within that network ought to assume that MTU is equal for
all machines within the same L2 network.

> >It seems to me to only clean solution is to set tap0 MTU so that it accounts for the
> >bridge encap overhead.
> 
> This will force _ALL_ deploy instances requiring tap0 MTU change in every cloud env.

Yes, alternatively emply routing, then PMTU should work.

> Current behavior leads over-mtu-sized packet push down to NIC, which should not
> happen anyway. And as I putted in another threads:
> Perform GSO for skb, then try to do ip segmentation if possible, If DF set, send back
> ICMP message. If DF is not set, apparently user want stack do ip segmentation, and
> All the GSO-ed skb will be sent out correctly as expected.

Well, the linux bridge implementation (especially bridge netfilter)
did/allows for a lot of layering violations and this has usually caused
a myriad of followup kludges to make one-more scenario work.

I still think that trying to make this work is a bad idea.
If hosts have different MTUs they should be in different l2 networks.

Alternatively, the Tunneling implementation should be opaque and do the
needed fragmentation to provide the illusion of identical MTUs.

That said, I don't see anything wrong with the patch per se, I just
dislike the concept.
