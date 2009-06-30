From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Wed, 1 Jul 2009 06:27:37 +0930
Message-ID: <20090701062737.6cac2193.lk-netdev@lk-netdev.nosense.org>
References: <1246379267.3749.42.camel@blaa>
	<20090630170027.GA22691@gondor.apana.org.au>
	<20090630.120608.193727499.davem@davemloft.net>
	<alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	markmc@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:50223 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbZF3U6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 16:58:10 -0400
In-Reply-To: <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 30 Jun 2009 22:16:35 +0200 (CEST)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Tuesday 2009-06-30 21:06, David Miller wrote:
> >Adding appropriate lists and persons to CC:
> >
> >> On Tue, Jun 30, 2009 at 05:27:47PM +0100, Mark McLoughlin wrote:
> >>> 
> >>> However, because nf_conntrack introduces an skb_orphan(), it is now
> >>> recommended that bridge-nf-call-iptables be disabled completely so as
> >>> to ensure features like TUNSETSNDBUF work as expected.
> >> 
> >> Patrick, does conntrack ever make sense for bridging? Perhaps
> >> we should get rid of that completely?
> 
> It makes sense absolutely. Consider:
> 
> * packet enters bridge
> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
> * (connection tracking entry is set up)
> * let bridging decision be "local delivery"

I really like this feature, although it is only because I've spent
time thinking about it, and it's usefulness, after having been burnt
quite a lot by it, due to it's quite strange side effects on traffic.
e.g. it'll defragment bridged IP packets, and then, if the outbound
bridge interface MTU is big enough, will send off large single ethernet
frames. If you're not expecting that, or don't work out what is
going on, you'll believe you're seeing the input traffic in the form
it arrived, and you'll believe it for quite a long time :-(

I'm not sure if it supposed to work on IP traffic carried within
bridge PPPoE/PPP, but it does - and that was very, very confusing to
work out what had happened too. PPPoE comes up, as does PPP and IPCP,
but forwarded IP packets are dropped unless there is a FORWARD
iptables rule.

I do agree though, either it should default to off, or the behaviour be
made far more prominent somehow.

Regards,
Mark.

