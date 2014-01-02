From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2 v3] ipv4: Cache dst in tunnels
Date: Thu, 2 Jan 2014 11:48:18 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021139500.32654@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f73.google.com ([209.85.212.73]:57778 "EHLO
	mail-vb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaABTsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:48:19 -0500
Received: by mail-vb0-f73.google.com with SMTP id f12so946140vbg.0
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 11:48:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 3 of caching routes in tunnels.

Addressed some comments from Eric in this series.

There are two patches (variants) in the series:
1) One dst cached for each tunnel.
2) Percpu dst cache per tunnel to avoid false sharing

Testing with GRE tunnels on a 32 CPU host with bnx2x (RSS support
for GRE) shows a modest improvement in CPU utilization with these
patches running 200 TCP_RR netperf clients.

Without patches
71.22% CPU utilization
138/180/244 90/95/99% latencies
1.30465e+06 CPU/tps
18318 CPU/tps

With patches
69.84%
142/186/249 90/95/99% latencies
1.30827e+06
18732 CPU/tps
