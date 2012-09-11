From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Tue, 11 Sep 2012 20:33:16 +0200
Message-ID: <1347388396.13103.658.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55039 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab2IKSdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 14:33:23 -0400
Received: by eekc1 with SMTP id c1so678386eek.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 11:33:22 -0700 (PDT)
In-Reply-To: <504F4063.9030706@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-11 at 16:45 +0300, Shlomo Pongartz wrote:
> Hi,
>=20
> I=E2=80=99m checking GRO aggregation with kernel 3.6.0-rc1+ using Int=
el ixgbe=20
> driver.
> The mtu is 1500 and GRO is on and so are SG and RX checksum.
> I ran iperf with default setting and monitor the receiver with tcpdum=
p.
> The tcpdump shows that the maximal aggregation is 32120 which is 21 *=
 1500.
> In the transmitter side tcpdump shows that TSO works better (~64K).
> I did a capture without GRO enabled to see if there was a difference=20
> between any flag
> of any two consecutive packets that forced flushing but didn't find=20
> anything.
> Is the GRO aggregation can be tuned.

It might mean NAPI runs while about 21 frames can be fetched at once
from NIC.

If receiver cpu is fast enough, it has no need to aggregate more segmen=
t
per skb.

Is LRO off or on ?

GRO itself has a 64Kbytes limit.
