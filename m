From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/3] mvneta: software TSO implementation
Date: Thu, 10 Apr 2014 19:57:59 -0300
Message-ID: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42457 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759191AbaDJW6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 18:58:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a software TSO implementation to our mvneta driver
which is already in use on a number platforms. When enabled, the TSO
shows both CPU usage reduction and throughput performance improvements.

The TSO feature can be completely disabled at runtime using ethtool:

  $ ethtool -K eth0 tso {on,off}

When TSO is disabled the only overhead remaining is the DMA buffers for the
TSO headers, allocated when the tx queues are initialized. Follow-up patches
can release/re-allocate these buffers upon TSO disabling/re-enabling.

In most of my tests I've used iperf where the improvement is most striking,
using a Plat'home Openblocks AX/3 board as the iperf client (tx).

Measuring the CPU usage with vmstat shows a substantial CPU usage drop when TSO
is on (~15% vs. ~25%). HTTP-based tests performed by Willy Tarreau have shown
nice performance improvements.

The first two patches are trivial cleanups, and the third patch does all the
hard work. The TSO implementation was originally prepared by Simon Guinot,
and I did some style massage and other cleaning.

Any comments about this is much appreciated.

Ezequiel Garcia (3):
  net: mvneta: Factorize feature setting
  net: mvneta: Clean mvneta_tx() sk_buff handling
  net: mvneta: Introduce a software TSO implementation

 drivers/net/ethernet/marvell/mvneta.c | 226 ++++++++++++++++++++++++++++++++--
 1 file changed, 215 insertions(+), 11 deletions(-)

-- 
1.9.1
