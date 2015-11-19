From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 22:53:02 +0100
Message-ID: <1447969982.3054314.444761185.363F62E7@webmail.messagingengine.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net>
 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
 <20151119.104811.1447518072450380661.davem@davemloft.net>
 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34838 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbbKSVxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:53:03 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 57210204BA
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 16:53:02 -0500 (EST)
In-Reply-To: <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Nov 19, 2015, at 22:41, Eric Dumazet wrote:
> On Thu, 2015-11-19 at 13:29 -0800, Tom Herbert wrote:
> > > We (TCP stack) compete with QUIC, based on UDP, which has no issues like
> > > that. We need to allow TCP sessions being signaled of a non temporary
> > > network disruption.
> > >
> > 
> > Eric, can you provide some detail on this statement?
> > 
> > I don't understand why QUIC wouldn't have this same issue. Seems like
> > it is still connection oriented just like TCP, so if the application
> > does a read expecting data from a peer and reverse reachability is
> > lost, the the read on the socket hang just like reading a TCP would.
> > If this is true, then the TCP solution would might actually be a
> > better since it allows a means for a third party (presumably a daemon
> > monitoring the network) to signal the application via closing specific
> > TCP sockets. I don't see how this could work in UDP especially if
> > these are unconnected sockets. What am I missing?
> 
> Quic simply sends UDP packets to a destination IP, port 443 (generally)
> 
> Say your UDP client binds to 0.0.0.0:<allocated/ephemeral port>
> 
> Kernel pick up source address given current working routing, on a per
> packet basis.
> 
> Their notion of 'flow' is provided by the use of an unique connection
> ID, included somewhere in the payload.
> 
> The replies from QUIC server will then reach the UDP port, because
> server learned the latest source IP known for the client.

You don't steer QUIC source addresses at all? I think most networking
failures are of transient nature thus the kernel routing subsystem is
not aware of link quality and packets get lost anyway e.g. in the air?
Thus binding on multiple interfaces and keepalives seem still
appropriate, no?

Bye,
Hannes
