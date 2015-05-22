From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF reassembed
 skbs
Date: Sat, 23 May 2015 00:52:04 +0200
Message-ID: <1432335124.3069974.276098697.5A39F0C2@webmail.messagingengine.com>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
 <20150522.150310.2248217318352290500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49802 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422679AbbEVWwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:52:06 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 09696209DE
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 18:52:05 -0400 (EDT)
In-Reply-To: <20150522.150310.2248217318352290500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015, at 21:03, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 22 May 2015 16:32:49 +0200
> 
> > IP (ttl 64, id 12345, offset 0, flags [+, DF], proto UDP (17), length 1204)
> >     192.168.7.1.42 > 10.23.42.2.42: UDP, length 1400
> > IP (ttl 64, id 12345, offset 1184, flags [DF], proto UDP (17), length 244)
> >     192.168.7.1 > 10.23.42.2: ip-proto-17
> 
> I almost consider a fragment with DF set an oxymoron.
> 
> How does this happen?
> 
> DF is a mechanism for PMTU discovery.  Therefore it is the end nodes
> which set DF on packets before fragmentation can even take place.
> Since DF is set initially, the logical consequence is that the packet
> cannot be legally fragmented along the way.
> 
> Are tunnels doing something to create this situation?

Hmm, interesting...

I think openvswitch still has this behavior that it always sets
ignore_df but DF bit control is up to user space.
Another situation where this can arise if a local socket with
ip_sk_ignore_df(sk) = 1 (we keep socket reference as long as possible ;)
) sends packets into a tunnel, like gre, where pmtudisc is enabled. It
should also look like those packets. This is because we don't clear
ignore_df during passing down the skb.

Bye,
Hannes
