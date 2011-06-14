From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Tue, 14 Jun 2011 13:53:37 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1106141302110.17529@wel-95.cs.helsinki.fi>
References: <20110611215919.5fc29c27@konijn> <1307850224.22348.626.camel@localhost> <20110612095131.6d924082@konijn> <1307869632.2872.106.camel@edumazet-laptop> <20110612113004.79f48f40@konijn> <1307875698.2872.130.camel@edumazet-laptop> <20110612132428.3e1a4593@konijn>
 <1307890657.2872.158.camel@edumazet-laptop> <20110612213726.4d203a6e@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41542 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab1FNKxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 06:53:38 -0400
In-Reply-To: <20110612213726.4d203a6e@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Jun 2011, Joris van Rantwijk wrote:

> On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Think of GRO being a receiver facility against stress/load, typically
> > in datacenter.
> > 
> > Only when receiver is overloaded, GRO kicks in and can coalesce
> > several frames before being handled in TCP stack in one run.
> 
> Ok, it now becomes clear to me that I have a different scenario in mind
> than GRO was designed to handle. I'm interested in LRO as a method
> to sustain 1 Gbit through a single TCP connection on a slow embedded
> computer.
> 
> > If receiver is so loaded that more than 2 frames are coalesced in a
> > NAPI run, it certainly helps to not allow sender to increase its cwnd
> > more than one SMSS. We probably are right before packet drops anyway.
> 
> Right. So unlike TSO, GRO is not a transparent, generally applicable
> performance improvement. It's more like a form of graceful degradation,
> helping a server to sustain overall throughput when it is already
> swamped in TCP traffic.
> 
> Thanks for your clarification. This has certainly solved some confusion
> on my side.

BTW, it wouldn't be impossible to create all those "missing" ACKs on the 
TCP layer relatively cheaply when receiving the GRO'ed super segment.  I'm 
certainly not opposed you coming up such patch which does all that minimal 
work needed on TCP layer but I think it requires also some TSO/GSO related 
problem solving because TSO/GSO as is won't let you create such super ACKs 
we'd want to send out on that single go.


-- 
 i.
