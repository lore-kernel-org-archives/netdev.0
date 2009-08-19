From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Kernel forwarding performance test regressions
Date: Wed, 19 Aug 2009 11:00:10 -0700
Message-ID: <20090819110010.53b630cd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51378 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbZHSSAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 14:00:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vyatta regularly runs RFC2544 performance tests as part of
the QA release regression tests. These tests are run using
a Spirent analyzer that sends packets at maximum rate and
measures the number of packets received.

The interesting (worst case) number is the forwarding percentage for
minimum size Ethernet packets.  For packets 1K and above all the packets
get through but for smaller sizes the system can't keep up.

The hardware is Dell based
CPU is Intel Dual Core E2220 @ 2.40GHz (or 2.2GHz)
NIC's are internal Broadcom (tg3).

Size	2.6.23	2.6.24	2.6.26	2.6.29	2.6.30
64	 14.%	 20%	 21%	 17%	 19%
128	 22	 33	 34	 28	 32
256	 37	 52	 58	 49	 54
512	 67	 85	 83	 85	 85
1024	100	100	100	100	100
1280	100	100	100	100	100
1518	100	100	100	100	100


Some other details: 
  * Hardware change between 2.6.24 -> 2.6.26 numbers
    went from 2.2 to 2.4Ghz

  * no SMP affinity (or irqbalance) is done,
    numbers are significantly better if IRQ's are pinned.
    2.6.26 goes from 20% to 32%

  * unidirectional numbers are 2X the bidirectional numbers:
    2.6.26 goes from 20% to 40%

  * this is single stream (doesn't help/use multiqueue)

  * system loads iptables but does not use it, so each packet
    sees the overhead of null rules.

So kernel 2.6.29 had an observable dip in performance
which seems to be mostly recovered in 2.6.30.

These are from our QA, not me so please don't ask me for
"please rerun with XX enabled", go run the same test
yourself with pktgen.


-- 
