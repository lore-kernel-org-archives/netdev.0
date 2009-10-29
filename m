From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 17:54:15 +0100
Message-ID: <d4374087ea190adaab597d765096a0ed.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Petlund" <apetlund@simula.no>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Arnd Hannemann" <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45849 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbZJ2QyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:54:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Andreas Petlund schrieb:
>> We have found no noticeable degradation of the goodput in a series of
experiments we have performed in order to map the effects of the
modifications. Furthermore, the modifications implemented in the
patches
>> are explicitly enabled only for applications where the developer knows
that streams will be thin, thus only a small subset of the streams will
apply the modifications.
>> Graphs presenting results from experiments performed to analyse latency
and fairness issues can be found here:
>> http://folk.uio.no/apetlund/lktmp/
>
> How often did you hit consecutive RTOs in these measurements?
> As I see you did a measurement with 512 thick vs. 512 thin streams. Lets
do a hypothetical calculation with only 512 "thin" streams. Lets further
assume the rtt is low, so that RTO is around 200ms. Assume each segment
has 128 Bytes (already very small...).
> Assume after a period of normal operation all streams are in
> timeout-based loss recovery. (e.g. because destination endpoint
> suddenly behaves like a black hole)
> As all streams are in timeout-based loss recovery, each stream
> will transmit 5 segments each second with your modification.
> This would result in a throughput around 512*5*1024bit = 2560 kbit/s and
a goodput of 0 kbit/s (because the receiver is a black hole). So you can
easily saturate a 2 MBit/s link, only with retransmissions.

I have not yet performed experiments where the receiver becomes a black
hole, but I recognise the problem. Eric Dumazet suggested that the
mechanism switch to exponential backoff after 6 linear retries. This would
avoid situation where the link stays congested indefinitely, and I will
implement this in the next iteration.

> Unfortunately in Germany an ADSL uplink of 786 kbit/s is still quite
common, and its already called "broadband"...

I believe that a subscriber for such an uplink would not keep several
hundred thin-stream connections, though accidents do happen.

> Regarding the "small subset", why have a global sysctl option, then? And
I think "tcp_stream_is_thin(tp)" will be true for every flow in the RTO
case, at least for consecutive RTOs.

The sysctl is ment for cases of proprietary code that will benefit from
the modifications. In our experiments, we have found it useful in many
cases for such applications (like game clients).

Regards,
Andreas




