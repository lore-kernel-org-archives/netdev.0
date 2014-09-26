From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 0/5] net: tcp: DCTCP congestion control algorithm
Date: Fri, 26 Sep 2014 22:37:31 +0200
Message-ID: <1411763856-14230-1-git-send-email-dborkman@redhat.com>
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	stephen@networkplumber.org, glenn.judd@morganstanley.com,
	dborkman@redhat.com, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754829AbaIZUh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 16:37:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the DataCenter TCP (DCTCP) congestion
control algorithm. Please see individual patches for the details.

The last patch adds DCTCP as a congestion control module, and previous
ones add needed infrastructure to extend the congestion control framework.

Joint work between Florian Westphal, Daniel Borkmann and Glenn Judd.

v3 -> v2:
 - No changes anywhere, just a resend as requested by Dave
 - Added Stephen's ACK
v1 -> v2:
 - Rebased to latest net-next
 - Addressed Eric's feedback, thanks!
  - Update stale comment wrt. DCTCP ECN usage
  - Don't call INET_ECN_xmit for every packet
 - Add dctcp ss/inetdiag support to expose internal stats to userspace

Thanks !

Daniel Borkmann (2):
  net: tcp: add flag for ca to indicate that ECN is required
  net: tcp: add DCTCP congestion control algorithm

Florian Westphal (3):
  net: tcp: assign tcp cong_ops when tcp sk is created
  net: tcp: split ack slow/fast events from cwnd_event
  net: tcp: more detailed ACK events and events for CE marked packets

 Documentation/networking/dctcp.txt |  43 +++++
 include/net/tcp.h                  |  78 ++++++---
 include/uapi/linux/inet_diag.h     |  13 +-
 net/ipv4/Kconfig                   |  26 ++-
 net/ipv4/Makefile                  |   1 +
 net/ipv4/tcp.c                     |   6 +-
 net/ipv4/tcp_cong.c                |  46 +++--
 net/ipv4/tcp_dctcp.c               | 344 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c               |  32 +++-
 net/ipv4/tcp_minisocks.c           |   5 +-
 net/ipv4/tcp_output.c              |  30 +++-
 net/ipv4/tcp_westwood.c            |  28 +--
 12 files changed, 574 insertions(+), 78 deletions(-)
 create mode 100644 Documentation/networking/dctcp.txt
 create mode 100644 net/ipv4/tcp_dctcp.c

-- 
1.7.11.7
