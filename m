From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC v2 PATCH 0/3] tcp: Parallel SYN brownies patch series to
	mitigate SYN floods
Date: Thu, 31 May 2012 15:39:53 +0200
Message-ID: <20120531133807.10311.79711.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:11005 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758032Ab2EaNhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 09:37:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is dubbed SYN brownies.  The purpose is mitigate
the effect of SYN flood DDoS attacks.  This is done by making the SYN
cookies stage parallel.  In normal (non-overload) situations SYN
packets are still processed under the bh_lock_sock().

This SYN brownies patch series will not be merged right away, as Eric
Dumazet is working on a fully parallel SYN stage.  Until that emerges
and gets integrated, I recommend people with SYN flood issues, to use
these patches to fix your immediate overload situations.

Thus, these patches can only be merged at Eric Dumazet's will/ACK, if
he determines they don't conflict with his work.

Only IPv4 TCP is handled here. The IPv6 TCP code also need to be
updated, but I'll deal with that part after, Eric Dumazet, have
settled on a fully parallel SYN processing stage.

This is patch set have been tested on top Linus'es tree of
commit v3.4-9209-gd590f9a.

---

Jesper Dangaard Brouer (3):
      tcp: SYN retransmits, fallback to slow-locked/no-cookie path
      tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
      tcp: extract syncookie part of tcp_v4_conn_request()


 net/ipv4/tcp_ipv4.c   |  154 +++++++++++++++++++++++++++++++++++++++++--------
 net/ipv4/tcp_output.c |   20 ++++--
 2 files changed, 144 insertions(+), 30 deletions(-)
