From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] netem: rate extension
Date: Sat, 26 Nov 2011 12:00:42 +0100
Message-ID: <1322305242.10212.9.camel@edumazet-laptop>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	 <1322187773-27768-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40011 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab1KZLAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 06:00:47 -0500
Received: by bke11 with SMTP id 11so5502898bke.19
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2011 03:00:45 -0800 (PST)
In-Reply-To: <1322187773-27768-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 03:22 +0100, Hagen Paul Pfeifer a =C3=
=A9crit :
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
> This patch implement rate feature which can be configured via tc. e.g=
:
>=20
> 	tc qdisc add dev eth0 root netem rate 10kbit
>=20
> To emulate a link of 5000byte/s and add an additional static delay of=
 10ms:
>=20
> 	tc qdisc add dev eth0 root netem delay 10ms rate 5KBps
>=20
> Note: similar to TBF the rate extension is bounded to the kernel timi=
ng
> system. Depending on the architecture timer granularity, higher rates=
 (e.g.
> 10mbit/s and higher) tend to transmission bursts. Also note: further =
queues
> living in network adaptors; see ethtool(8).
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
