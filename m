From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 0/5] net: tcp: DCTCP congestion control algorithm
Date: Sat, 20 Sep 2014 23:29:17 +0200
Message-ID: <1411248562-26581-1-git-send-email-fw@strlen.de>
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38438 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754861AbaITV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:29:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the DataCenter TCP (DCTCP) congestion
control algorithm. Please see individual patches for the details.

Over the last couple of months, we have resolved all outstanding issues
from last time in the background and as agreed with Dave, we're now
sending v2 of the set.

The last patch adds DCTCP as a congestion control module, and previous
ones add needed infrastructure to extend the congestion control framework.

Joint work between Florian Westphal, Daniel Borkmann and Glenn Judd.

v1 -> v2:
 - Rebased to latest net-next
 - Addressed Eric's feedback, thanks!
  - Update stale comment wrt. DCTCP ECN usage
  - Don't call INET_ECN_xmit for every packet
 - Add dctcp ss/inetdiag support to expose internal stats to userspace

Thanks!

Daniel Borkmann (2):
  net: tcp: add flag for ca to indicate that ECN is required
  net: tcp: add DCTCP congestion control algorithm

Florian Westphal (3):
  net: tcp: assign tcp cong_ops when tcp sk is created
  net: tcp: split ack slow/fast events from cwnd_event
  net: tcp: more detailed ACK events and events for CE marked packets

 Documentation/networking/dctcp.txt |   43 ++++
 include/net/tcp.h                  |   80 ++++++--
 include/uapi/linux/inet_diag.h     |   13 +
 net/ipv4/Kconfig                   |   26 ++
 net/ipv4/Makefile                  |    1 
 net/ipv4/tcp.c                     |    6 
 net/ipv4/tcp_cong.c                |   46 ++--
 net/ipv4/tcp_dctcp.c               |  344 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c               |   36 +++
 net/ipv4/tcp_minisocks.c           |    5 
 net/ipv4/tcp_output.c              |   30 ++-
 net/ipv4/tcp_westwood.c            |   28 +--
 12 files changed, 577 insertions(+), 81 deletions(-)
