From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data post
 active-close
Date: Wed, 18 Nov 2015 16:54:17 +0100
Message-ID: <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151118153621.GA5860@breakpoint.cc>
 <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcelo.leitner@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41162 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755008AbbKRPyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:54:18 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id D60AA2099E
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 10:54:17 -0500 (EST)
In-Reply-To: <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015, at 16:46, Eric Dumazet wrote:
> On Wed, 2015-11-18 at 16:36 +0100, Florian Westphal wrote:
> 
> > Yes, but we kill the socket.
> > 
> > I should have added
> > 
> > 0.400 `ss -nito state time-wait`
> > 
> > as last line...
> > 
> > Before patch: no output
> > after patch: tw socket shown.
> > 
> > The on-wire behavior doesn't change unless further packets arrive.
> > Old behaviour: more RST
> > New behaviour: acks+tw timer restart
> 
> Just add few more incoming packets to the packetdrill test then ?
> 
> Also, is your customer really _not_ using TCP timestamps ?

Windows mostly does not use TCP timestamps. Also we have cases were
security folks tell customers to turn off timestamps as they enable
attackers to guess uptime. :(

> This is kind of a requirement for port reuse anyway.
> 
> Anyway, having a TIMEWAIT setup after sending a RST makes little sense
> to me.
> 
> When a RST packet is sent, the remote peer will forget everything about
> this previous connection, and another connect() might reuse the tuple
> and I do not think we should forbid this. Normal PAWS checks were
> invented for a good reason.

Still, the RST packet can be dropped along the way. So the teardown of
the socket on the other side might not happen.

Bye,
Hannes
