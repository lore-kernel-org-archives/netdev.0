From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 0/5] tcp: IPv6 support for fastopen server
Date: Sun, 11 May 2014 20:22:08 -0700
Message-ID: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:53045 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaELDWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:50 -0400
Received: by mail-ie0-f201.google.com with SMTP id rp18so621090iec.0
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add IPv6 support for fastopen server. To minimize
code duplication in IPv4 and IPv6, the current v4 only code is
refactored and common code is moved into net/ipv4/tcp_fastopen.c.

Also the current code uses a different function from
tcp_v4_send_synack() to send the first SYN-ACK in fastopen.
The new code eliminates this separate function by refactoring the
child-socket and syn-ack creation code.  After these refactoring
in the first four patches, we can easily add the fastopen code in
IPv6 by changing corresponding IPv6 functions.

Note Fast Open client already supports IPv6. This patch is for
the server-side (passive open) IPv6 support only.

Daniel Lee (1):
  tcp: IPv6 support for fastopen server

Yuchung Cheng (4):
  tcp: move fastopen functions to tcp_fastopen.c
  tcp: simplify fast open cookie processing
  tcp: use tcp_v4_send_synack on first SYN-ACK
  tcp: improve fastopen icmp handling

 include/linux/tcp.h      |   5 -
 include/net/tcp.h        |  15 ++-
 net/ipv4/tcp_fastopen.c  | 219 +++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_ipv4.c      | 277 +++++------------------------------------------
 net/ipv4/tcp_minisocks.c |  31 ++++++
 net/ipv4/tcp_output.c    |  23 +---
 net/ipv6/tcp_ipv6.c      |  62 ++++++++---
 7 files changed, 323 insertions(+), 309 deletions(-)

-- 
1.9.1.423.g4596e3a
