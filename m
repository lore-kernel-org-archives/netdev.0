From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 21:37:26 +0200
Message-ID: <20110612213726.4d203a6e@konijn>
References: <20110611215919.5fc29c27@konijn>
	<1307850224.22348.626.camel@localhost>
	<20110612095131.6d924082@konijn>
	<1307869632.2872.106.camel@edumazet-laptop>
	<20110612113004.79f48f40@konijn>
	<1307875698.2872.130.camel@edumazet-laptop>
	<20110612132428.3e1a4593@konijn>
	<1307890657.2872.158.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr12.xs4all.nl ([194.109.24.32]:1860 "EHLO
	smtp-vbr12.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab1FLThc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 15:37:32 -0400
In-Reply-To: <1307890657.2872.158.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Think of GRO being a receiver facility against stress/load, typically
> in datacenter.
> 
> Only when receiver is overloaded, GRO kicks in and can coalesce
> several frames before being handled in TCP stack in one run.

Ok, it now becomes clear to me that I have a different scenario in mind
than GRO was designed to handle. I'm interested in LRO as a method
to sustain 1 Gbit through a single TCP connection on a slow embedded
computer.

> If receiver is so loaded that more than 2 frames are coalesced in a
> NAPI run, it certainly helps to not allow sender to increase its cwnd
> more than one SMSS. We probably are right before packet drops anyway.

Right. So unlike TSO, GRO is not a transparent, generally applicable
performance improvement. It's more like a form of graceful degradation,
helping a server to sustain overall throughput when it is already
swamped in TCP traffic.

Thanks for your clarification. This has certainly solved some confusion
on my side.

Joris.
