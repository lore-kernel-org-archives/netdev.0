From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 11:30:04 +0200
Message-ID: <20110612113004.79f48f40@konijn>
References: <20110611215919.5fc29c27@konijn>
	<1307850224.22348.626.camel@localhost>
	<20110612095131.6d924082@konijn>
	<1307869632.2872.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr7.xs4all.nl ([194.109.24.27]:2655 "EHLO
	smtp-vbr7.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab1FLJaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 05:30:09 -0400
In-Reply-To: <1307869632.2872.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > As far as I can see, current code will send just one ACK per
> > coalesced GRO bundle, while the sender expects one ACK per two
> > segments.

> One ACK carries an implicit ack for _all_ previous segments. If sender
> only 'counts' ACKs, it is a bit dumb...

It may be dumb, but it's what the RFCs recommend and it's what Linux
implements.

RFC 5681:
  "During slow start, a TCP increments cwnd by at most SMSS bytes for
   each ACK received that cumulatively acknowledges new data."

In Linux, each incoming ACK causes one call to tcp_cong_avoid(),
which causes one call to tcp_slow_start() - assuming the connection is
in slow start - which increases the congestion window by one MSS.
Am I mistaken?

Please note I'm talking about managing the congestion window.
Of course I agree that each ACK implicitly covers all previous segments
for the purpose of retransmission management. But congestion
management is a different story.

Joris.
