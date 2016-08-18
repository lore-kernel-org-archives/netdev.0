From: Florian Westphal <fw@strlen.de>
Subject: [RFC 0/3] tcp: increase resilence vs. blind data injection
Date: Thu, 18 Aug 2016 14:48:44 +0200
Message-ID: <1471524527-10029-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51580 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754023AbcHRNAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 09:00:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series introduces a new tcp_timestamps=2 mode.

When enabled, out-of-order packets that carry data are also subject
to a range check of TSecr (timestamp echo).

Current kernels use a global timestamp echo, i.e.  the timestamp values
are known.

Therefore first patch adds per connection randomzation of timestamp.
The ISN generator is re-used for this purpose to get same offset
for all connections with identical connection quadruple.

Second patch adds the new timestamp mode, default is not changed.

Third patch adds a MIB counter to track when we drop skb because
of the new facility.

Syncookies are not yet converted to use tsoff.
Depending on how discussion about this set will turn out I will add
this for the v1 submit.

 Documentation/networking/ip-sysctl.txt |    8 ++++--
 include/linux/tcp.h                    |    1 
 include/net/secure_seq.h               |   13 ++++++---
 include/net/tcp.h                      |    2 -
 include/uapi/linux/snmp.h              |    1 
 net/core/secure_seq.c                  |   19 +++++++++-----
 net/ipv4/proc.c                        |    1 
 net/ipv4/syncookies.c                  |    1 
 net/ipv4/tcp_input.c                   |   43 ++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_ipv4.c                    |   30 +++++++++++++++--------
 net/ipv4/tcp_minisocks.c               |    4 ++-
 net/ipv4/tcp_output.c                  |    2 -
 net/ipv6/syncookies.c                  |    1 
 net/ipv6/tcp_ipv6.c                    |   28 +++++++++++++--------
 14 files changed, 118 insertions(+), 36 deletions(-)
