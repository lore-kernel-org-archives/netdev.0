From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 19:27:49 +0100
Message-ID: <1447957669.2293924.444570833.0E151DD6@webmail.messagingengine.com>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
 <CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
 <20151119.130923.186891318318651425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, zenczykowski@gmail.com, lorenzo@google.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, dtor@google.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49911 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752698AbbKSS1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:27:50 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 9B167204B6
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:27:49 -0500 (EST)
In-Reply-To: <20151119.130923.186891318318651425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 19:09, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 19 Nov 2015 09:38:37 -0800
> 
> > 1) We need transparency. If a third party kills a TCP connection then
> > the application should be informed of specifically that. This seems
> > easy enough to just pick an appropriate error number as I suggested.
> 
> Agreed.
> 
> > 2) We need constraints. This feature seems to be specific to a very
> > narrow use case. It is not at all clear to me if there are any
> > legitimate uses cases beyond Android, enabling this by default in the
> > stack creates a non-zero amount of risk and liability for abuse. It
> > seems like this should be an opt-in sort of feature, with a kernel
> > CONFIG or maybe opt-in per socket.
> 
> And this will probably be the point of contention.

For me this looks like the revoke(const char *) syscall for TCP. I would
be willing to enable this by default if we can guarantee that for
TIMEWAIT_LEN we don't have reuse of that quadruple. I don't see anything
bad happening by tearing down any connection besides too quick reuse of
that identifier, so why not enable it by default for everyone? I
certainly am often in the situation that I would like to kill
connections on my laptop which are hanging and I know the reason,
actually. A nice user interface would be certainly a place. Also we
should of course wake up any poll_wait_time wchans waiting on the socket
so user space can move forward.

Probably I would really like to see that we send a reset, even though it
won't probably reach its destination in case the source address is
removed from the system.

I will research the semantics behind tcpdrop:
<http://www.freebsd.org/cgi/man.cgi?query=tcpdrop&apropos=0&sektion=0&manpath=FreeBSD+10.2-RELEASE&arch=default&format=html>

Bye,
Hannes
