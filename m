From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 21:42:53 +0100
Message-ID: <20140113204253.GI6586@order.stressinduktion.org>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org> <20140113.112504.922587457597727366.davem@davemloft.net> <CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	steffen.klassert@secunet.com, fweimer@redhat.com
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33432 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbaAMUmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:42:54 -0500
Content-Disposition: inline
In-Reply-To: <CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 02:35:31PM -0500, John Heffner wrote:
> On Mon, Jan 13, 2014 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
> > From: hannes@stressinduktion.org
> > Date: Thu,  9 Jan 2014 10:01:14 +0100
> >
> >> After a lot of back and forth I want to propose these changes regarding
> >> path mtu hardening and give an outline why I think this is the best way
> >> how to proceed:
> >
> > I'm not going to fight this any more even though I still disagree with
> > these changes.  John Heffner has not provided a coherent strong
> > argument for not doing this, in fact the counter arguments were
> > extremely vague.
> >
> > I am pretty sure that now my worst fears will be realized and every
> > single distribution will not use the kernel's default, and everyone
> > will get this behavior rather than adminstrators making well informed
> > decisions about how to defend against these kind of situations when
> > enabling routing, or whether they'd even be exposed to the issue at
> > all in a particular setup.
> >
> > Such is life.

:/

> My only comment would be not to look to me as the only source of
> reason not to include this change.  I've been largely disconnected
> from Linux development for several years and don't have time to get
> into a protracted discussion on this topic.
> 
> FWIW, I still have doubts as to whether this is the best approach to
> solving the underlying problem.  I still haven't heard any reason why
> firewall rules and other administrative best practices, such as using

Because we currently cannot easily filter icmp payloads and check whether
it is in a response for a local socket or a malicious one.

> separate management and forwarding interfaces on a router, don't
> practically solve this problem.

I don't think this is practiable, especially in times of small devices
doing routing (e.g. smartphones).

> I'd also be curious to hear what
> dedicated routing operating systems do, and why I haven't heard about
> widespread fragmentation DoS attacks.

My old Cisco didn't honour those pmtu packets (at least in default
configuration) and FreeBSD only accepts pmtu information for TCP sockets
where it also verifies the sequence number. It does not react to pmtu
notifications in response to icmp or udp payloads.

Routing path does use the pmtu values on FreeBSD, though. But it is much
harder to inject path mtu packets there because, as said, they are only
accepted for tcp.

> That said, this probably won't deeply break anything, but adds yet
> more complexity in the core of the network stack...

Actually I feel a bit emberrased how these changes went in. At first I
thought they wouldn't be that much of a problem. I'll try to improve my
communiation skills and try to listen more carefully.

Thank you, David and John!

Greetings,

  Hannes
