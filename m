From: Shlomo Pongratz <shlomop@mellanox.com>
Subject: RE: GRO aggregation
Date: Tue, 11 Sep 2012 19:24:26 +0000
Message-ID: <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
References: <504F4063.9030706@mellanox.com>
	 ,<1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>,<1347390113.13103.660.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:58154 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754165Ab2IKT1R convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 15:27:17 -0400
In-Reply-To: <1347390113.13103.660.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet [eric.dumazet@gmail.com]
Sent: Tuesday, September 11, 2012 10:02 PM
To: Shlomo Pongratz
Cc: netdev@vger.kernel.org
Subject: RE: GRO aggregation

On Tue, 2012-09-11 at 18:49 +0000, Shlomo Pongratz wrote:

> I disabled the LRO. I actually tried the all the 4 options and found that LRO, GRO, LRO+GRO gives the same results for ixgbe w.r.t aggregation size (didn't check for throughput or latency).
> Is there a timeout that flushes the aggregated SKBs before 64K were aggregated?

At the end of NAPI run, we flush the gro state.

It basically means that an interrupt came, and we fetched 21 frames from
the NIC.

To get more packets per interrupt, you might try to slow down your
cpu ;)

But I dont get the point.


I see that in ixgbe the weight for the NAPI is 64 (netif_napi_add). So if packets are arriving in high rate then an the CPU is fast enough to collect the packets as they arrive, assuming packets continue to arrives while the NAPI runs. Then it should have aggregate more. So we will have less passes trough the stack.

Shlomo