From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: GRO aggregation
Date: Tue, 11 Sep 2012 21:01:53 +0200
Message-ID: <1347390113.13103.660.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 ,<1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongratz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35160 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759171Ab2IKTB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 15:01:58 -0400
Received: by eekc1 with SMTP id c1so698341eek.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 12:01:57 -0700 (PDT)
In-Reply-To: <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-11 at 18:49 +0000, Shlomo Pongratz wrote:

> I disabled the LRO. I actually tried the all the 4 options and found that LRO, GRO, LRO+GRO gives the same results for ixgbe w.r.t aggregation size (didn't check for throughput or latency).
> Is there a timeout that flushes the aggregated SKBs before 64K were aggregated?

At the end of NAPI run, we flush the gro state.

It basically means that an interrupt came, and we fetched 21 frames from
the NIC.

To get more packets per interrupt, you might try to slow down your
cpu ;)

But I dont get the point.
