From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Thu, 24 Nov 2011 23:14:58 +0100
Message-ID: <1322172898.2872.7.camel@edumazet-laptop>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41652 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1KXWPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 17:15:03 -0500
Received: by bke11 with SMTP id 11so3513015bke.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 14:15:02 -0800 (PST)
In-Reply-To: <1322156378-23257-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 novembre 2011 =C3=A0 18:39 +0100, Hagen Paul Pfeifer a =C3=A9=
crit :
> Currently netem is not in the ability to emulate channel bandwidth. O=
nly static
> delay (and optional random jitter) can be configured.
>=20
> To emulate the channel rate the token bucket filter (sch_tbf) can be =
used.  But
> TBF has some major emulation flaws. The buffer (token bucket depth/ra=
te) cannot
> be 0. Also the idea behind TBF is that the credit (token in buckets) =
fills if
> no packet is transmitted. So that there is always a "positive" credit=
 for new
> packets. In real life this behavior contradicts the law of nature whe=
re
> nothing can travel faster as speed of light. E.g.: on an emulated 100=
0 byte/s
> link a small IPv4/TCP SYN packet with ~50 byte require ~0.05 seconds =
- not 0
> seconds.
>=20
> Netem is an excellent place to implement a rate limiting feature: sta=
tic
> delay is already implemented, tfifo already has time information and =
the
> user can skip TBF configuration completely.
>=20
> This patch implement rate latency feature which can be configured via
> tc. e.g:
>=20
> 	tc qdisc add dev eth0 root netem ratelatency 10kbit
>=20
> To emulate a link of 5000byte/s and add an additional static delay of=
 10ms:
>=20
> 	tc qdisc add dev eth0 root netem delay 10ms ratelatency 5KBps
>=20
> Note: similar to TBF the rate-latency extension is bounded to the ker=
nel timing
> system. Depending on the architecture timer granularity, higher rates=
 (e.g.
> 10mbit/s and higher) tend to transmission bursts. Also note: further =
queues
> living in network adaptors; see ethtool(8).
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  include/linux/pkt_sched.h |    5 +++++
>  net/sched/sch_netem.c     |   40 +++++++++++++++++++++++++++++++++++=
+++++
>  2 files changed, 45 insertions(+), 0 deletions(-)

I like this patch, this is a useful extension.

Only point is why you chose ratelatency instead of rate ?

We want to emulate a real link, and yes, a 1000 bytes packet must be
delayed _before_ we deliver it to the device, but its a detail of how
works netem.

The usual word we use to describe a 1Mbps link is "1Mbps rate" ;)
