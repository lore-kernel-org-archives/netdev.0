From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 13:41:04 -0800
Message-ID: <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	 <20151119.005318.838757439536205791.davem@davemloft.net>
	 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	 <20151119.104811.1447518072450380661.davem@davemloft.net>
	 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35927 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbKSVlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:41:07 -0500
Received: by pacdm15 with SMTP id dm15so93163545pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:41:06 -0800 (PST)
In-Reply-To: <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 13:29 -0800, Tom Herbert wrote:
> > We (TCP stack) compete with QUIC, based on UDP, which has no issues like
> > that. We need to allow TCP sessions being signaled of a non temporary
> > network disruption.
> >
> 
> Eric, can you provide some detail on this statement?
> 
> I don't understand why QUIC wouldn't have this same issue. Seems like
> it is still connection oriented just like TCP, so if the application
> does a read expecting data from a peer and reverse reachability is
> lost, the the read on the socket hang just like reading a TCP would.
> If this is true, then the TCP solution would might actually be a
> better since it allows a means for a third party (presumably a daemon
> monitoring the network) to signal the application via closing specific
> TCP sockets. I don't see how this could work in UDP especially if
> these are unconnected sockets. What am I missing?

Quic simply sends UDP packets to a destination IP, port 443 (generally)

Say your UDP client binds to 0.0.0.0:<allocated/ephemeral port>

Kernel pick up source address given current working routing, on a per
packet basis.

Their notion of 'flow' is provided by the use of an unique connection
ID, included somewhere in the payload.

The replies from QUIC server will then reach the UDP port, because
server learned the latest source IP known for the client.
