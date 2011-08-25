From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [BUG] tcp : how many times a frame can possibly be retransmitted
 ?
Date: Thu, 25 Aug 2011 13:07:38 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108251251060.21709@wel-95.cs.helsinki.fi>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1108250142030.11551@melkinpaasi.cs.helsinki.fi>  <1314226834.6797.5.camel@edumazet-laptop>  <alpine.DEB.2.00.1108251150050.12780@wel-95.cs.helsinki.fi>
 <1314265254.2387.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-2137743852-1314266359=:21709"
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57859 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab1HYKHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 06:07:40 -0400
In-Reply-To: <1314265254.2387.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-ID: <alpine.DEB.2.00.1108251306320.21709@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-2137743852-1314266359=:21709
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1108251300281.21709@wel-95.cs.helsinki.fi>

On Thu, 25 Aug 2011, Eric Dumazet wrote:

> Le jeudi 25 août 2011 à 11:56 +0300, Ilpo Järvinen a écrit :
> 
> > So you think that this is not true: ?
> > 
> >         /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
> >          * guarantees that rto is higher.
> >          */
> > 
> > ...it would still be smaller than 1sec though, but certainly not going to 
> > cause flooding either. Default tcp_rto_min should be 200ms so it's 
> > 5pkts+5ICMP sent, received and processed per second. Which doesn't sound 
> > that bad CPU load?!?
> > 
> 
> Unless you have 100.000 active sessions maybe ?
> 
> Some years ago, I helped people running servers with more than 1.000.000
> long living active sessions, and a temporary network disruption was
> already very critical at that time, with old kernels (At that time, IP
> route cache could blow away and consume too much ram or cpu time, things
> are now under control)
> 
> I guess they would not try a new kernel :(
> 
> > It is unclear to me how tp->rttvar could become smaller than 
> > tcp_rto_min().
> 
> I believe this part is fine Ilpo.
> 
> As long as we handle few tcp sessions, its fine to send 5 messages per
> session per second.

Yeah, thanks for the clarification. I was just confused by the initial 
wording of yours which seemed to imply that we could, at worst, end up 
doing it with full rate without any timers.

To me it seems that both cases are quite valid, with pretty much 
contradicting goals.


-- 
 i.
--8323329-2137743852-1314266359=:21709--
