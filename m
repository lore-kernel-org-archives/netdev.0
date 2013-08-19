From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [RFC 0/2] Account for duplicate ACKs with invalid SACK-blocks
Date: Mon, 19 Aug 2013 14:22:46 -0700
Message-ID: <52128CA6.6090001@fatooh.org>
References: <1376935800.4226.71.camel@edumazet-glaptop> <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Phil Oester <kernel@linuxace.com>,
	Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:47924 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab3HSVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 17:22:48 -0400
In-Reply-To: <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-08-19 12:29, Christoph Paasch wrote:
> There exist sequence-number rewriting middleboxes, who do not modify the 
> sequence-number in the SACK-blocks.
> Duplicate acknowledgments with these (invalid) SACK-blocks will not be
> accounted in sacked_out, and thus no fast-retransmit will trigger.
> So, the only way to recover from a packet-loss is through an RTO,
> effectively killing the performance of TCP in this case.
> 
> Performance-results can be seen here:
> http://tools.ietf.org/agenda/87/slides/slides-87-tcpm-11.pdf
> 
> Another solution might be to simply disable SACK, as soon as an invalid
> SACK-block has been received (as suggested by Phil Oester). This however
> might be too aggressive.
> 
> Christoph Paasch (2):
>   Use acked_out for reno-style ack acounting instead of sacked_out
>   Account acked_out in sack, if the sack is invalid
> 
>  include/linux/tcp.h      |   1 +
>  include/net/tcp.h        |  17 +++++---
>  net/ipv4/tcp_input.c     | 103 ++++++++++++++++++++++++++++++++---------------
>  net/ipv4/tcp_minisocks.c |   1 +
>  net/ipv4/tcp_output.c    |   6 +--
>  net/ipv4/tcp_timer.c     |   2 +-
>  6 files changed, 89 insertions(+), 41 deletions(-)

I tested this patchset, and, unfortunately, the behavior seems to be the
same.

I'm still planning on working with the Cisco device, when I can get some
of the network admin's time, but that won't happen immediately.

Thanks,
Corey
