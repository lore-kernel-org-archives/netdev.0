From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu, 23 Aug 2012 11:57:05 +0100
Message-ID: <50360C81.6000009@draigBrady.com>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030301Ab2HWK5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 06:57:11 -0400
In-Reply-To: <1344559958-29162-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2012 01:52 AM, Bruce "Brutus" Curtis wrote:
> From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
>=20
> TCP/IP loopback socket pair stack bypass, based on an idea by, and
> rough upstream patch from, David Miller <davem@davemloft.net> called
> "friends", the data structure modifcations and connection scheme are
> reused with extensive data-path changes.
>=20
> A new sysctl, net.ipv4.tcp_friends, is added:
>   0: disable friends and use the stock data path.
>   1: enable friends and bypass the stack data path, the default.
>=20
> Note, when friends is enabled any loopback interpose, e.g. tcpdump,
> will only see the TCP/IP packets during connection establishment and
> finish, all data bypasses the stack and instead is delivered to the
> destination socket directly.
>=20
> Testing done on a 4 socket 2.2GHz "Quad-Core AMD Opteron(tm) Processo=
r
> 8354 CPU" based system, netperf results for a single connection show
> increased TCP_STREAM throughput, increased TCP_RR and TCP_CRR transac=
tion
> rate for most message sizes vs baseline and comparable to AF_UNIX.
>=20
> Significant increase (up to 4.88x) in aggregate throughput for multip=
le
> netperf runs (STREAM 32KB I/O x N) is seen.

Nice!

Just to quantify the loopback testing compat issue.
I often do stuff like the following to test latency.
Will that be impacted?

  tc qdisc add dev lo root handle 1:0 netem delay 20msec

As for the stated tcpdump change,
I don't suppose it would be possible to dynamically
disable this (for new connections at least)
while lo is being dumped?

cheers,
P=E1draig.
