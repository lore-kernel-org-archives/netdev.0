From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [net-next 0/3] Improve UDP multicast receive latency
Date: Tue,  1 Oct 2013 14:33:42 -0500
Message-ID: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:41496 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750881Ab3JATeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 15:34:24 -0400
Received: by mail-oa0-f43.google.com with SMTP id f4so5335302oah.30
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 12:34:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The removal of the routing cache in 3.6 had impacted the latency of our
UDP multicast workload.  This patch series brings down the latency to
what we were seeing with 3.4.

Patch 1 "udp: Only allow busy read/poll on connected sockets" is mostly
done for correctness and because it allows unifying the unicast and
multicast paths when a socket is found in early demux.  It can also
improve latency for a connected multicast socket if busy read/poll is
used.

Patches 2&3 remove the fib lookups and restore latency for our workload
to the pre 3.6 levels.

Benchmark results from a netperf UDP_RR test:
3.11 kernel   90596.44 transactions/s
3.11 + series 91792.70 transactions/s

Benchmark results from a fio 1 byte UDP multicast pingpong test
(Multicast one way unicast response):
3.11 kernel   12.647us RTT
3.11 + series 12.233us RTT

Shawn Bohrer (3):
  udp: Only allow busy read/poll on connected sockets
  udp: Add udp early demux
  net: ipv4 only populate IP_PKTINFO when needed

 include/net/ip.h       |    2 +-
 include/net/sock.h     |    2 +-
 include/net/udp.h      |    1 +
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/ip_sockglue.c |    5 +-
 net/ipv4/raw.c         |    2 +-
 net/ipv4/udp.c         |  160 +++++++++++++++++++++++++++++++++++++++++------
 net/ipv6/udp.c         |    5 +-
 8 files changed, 150 insertions(+), 28 deletions(-)

-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
