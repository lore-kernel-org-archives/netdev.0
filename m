From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: TCP cache performance
Date: Mon, 07 Jan 2008 17:22:51 -0800
Message-ID: <4782D06B.30706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lachlan Andrew <lachlan.andrew@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:17076 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215AbYAHBdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 20:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been continuing off and on to investigate TCP performance issues.
As has been noted before on this list, loss and subsequent processing
can lead to spikes in the measured RTT which confuse delay-based
congestion control algorithms.

I've done some experiments that indicate that cache size is a
significant limiting factor here. My desktop machine with a 2.4 GHz Core
Duo and 4 MB cache quite noticeably outperforms our experiment servers,
which have two dual-core Xeons at 2.66 GHz but only 512 KB cache. At 400
Mbps with 40ms round-trip delay and 1024-packet buffer the desktop
behaves fairly normally, although there is still a large RTT spike at
the start of the flow due to slow-start. The servers show large RTT
spikes at each loss event, as well as some timeouts.

This suggests that efforts to improve TCP performance should focus on
cache usage rather than just processing time.

Plots of cwnd, RTT, and CPU load are available here:

512K cache:
http://wil-ns.cs.caltech.edu/benchmark.tmp/265/2flow--ALG=illinois-BUF=1024-BUF_tgt=1333,1.0-BW=400M-GAP=150-LEN=600-RTT=40--1/

4M cache:
http://wil-ns.cs.caltech.edu/benchmark.tmp/266/2flow--ALG=illinois-BUF=1024-BUF_tgt=1333,1.0-BW=400M-GAP=150-LEN=600-RTT=40--1/

Tests were done with net-2.6 (2.6.23.1 gives similar results though)
using tcp_probe to capture data.

-Tom

