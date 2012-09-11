From: Shlomo Pongratz <shlomop@mellanox.com>
Subject: RE: GRO aggregation
Date: Tue, 11 Sep 2012 18:49:19 +0000
Message-ID: <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
References: <504F4063.9030706@mellanox.com>,<1347388396.13103.658.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:42241 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758404Ab2IKStX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 14:49:23 -0400
In-Reply-To: <1347388396.13103.658.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet [eric.dumazet@gmail.com]
Sent: Tuesday, September 11, 2012 9:33 PM
To: Shlomo Pongratz
Cc: netdev@vger.kernel.org
Subject: Re: GRO aggregation

On Tue, 2012-09-11 at 16:45 +0300, Shlomo Pongartz wrote:
> Hi,
>
> I=92m checking GRO aggregation with kernel 3.6.0-rc1+ using Intel ixg=
be
> driver.
> The mtu is 1500 and GRO is on and so are SG and RX checksum.
> I ran iperf with default setting and monitor the receiver with tcpdum=
p.
> The tcpdump shows that the maximal aggregation is 32120 which is 21 *=
 1500.
> In the transmitter side tcpdump shows that TSO works better (~64K).
> I did a capture without GRO enabled to see if there was a difference
> between any flag
> of any two consecutive packets that forced flushing but didn't find
> anything.
> Is the GRO aggregation can be tuned.

It might mean NAPI runs while about 21 frames can be fetched at once
from NIC.

If receiver cpu is fast enough, it has no need to aggregate more segmen=
t
per skb.

Is LRO off or on ?

GRO itself has a 64Kbytes limit.

Hi Eric.

I disabled the LRO. I actually tried the all the 4 options and found th=
at LRO, GRO, LRO+GRO gives the same results for ixgbe w.r.t aggregation=
 size (didn't check for throughput or latency).
Is there a timeout that flushes the aggregated SKBs before 64K were agg=
regated?

Shlomo
