From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH v2 0/3] tcp: TCP Fast Open, Server Side
Date: Fri, 31 Aug 2012 15:29:10 -0700
Message-ID: <1346452153-28690-1-git-send-email-hkchu@google.com>
Cc: sivasankar@cs.ucsd.edu, therbert@google.com,
	netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>
To: davem@davemloft.net, ycheng@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.213.202]:65492 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab2HaW3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 18:29:22 -0400
Received: by yenq6 with SMTP id q6so397510yen.1
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 15:29:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch series provides the server (passive open) side code
for TCP Fast Open. Together with the earlier client side patches
it completes the TCP Fast Open implementation.

The server side Fast Open code accepts data carried in the SYN
packet with a valid Fast Open cookie, and passes it to the
application right away, allowing application to send back response
data, all before TCP's 3-way handshake finishes.

A simple cookie scheme together with capping the number of
outstanding TFO requests (still in TCP_SYN_RECV state) to a limit
per listener forms the main line of defense against spoofed SYN
attacks.

For more details about TCP Fast Open see our IETF internet draft
at http://www.ietf.org/id/draft-ietf-tcpm-fastopen-01.txt
and a research paper at
http://conferences.sigcomm.org/co-next/2011/papers/1569470463.pdf

A prototype implementation was first developed by Sivasankar
Radhakrishnan (sivasankar@cs.ucsd.edu).

A patch based on an older version of Linux kernel has been
undergoing internal tests at Google for the past few months.

Jerry Chu (3):
  tcp: TCP Fast Open Server - header & support functions
  tcp: TCP Fast Open Server - support TFO listeners
  tcp: TCP Fast Open Server - main code path

 Documentation/networking/ip-sysctl.txt |   29 +++-
 include/linux/snmp.h                   |    4 +
 include/linux/tcp.h                    |   45 +++++-
 include/net/request_sock.h             |   49 +++++--
 include/net/tcp.h                      |   52 +++++-
 net/core/request_sock.c                |   95 +++++++++++
 net/ipv4/af_inet.c                     |   28 ++++-
 net/ipv4/inet_connection_sock.c        |   57 ++++++-
 net/ipv4/proc.c                        |    4 +
 net/ipv4/syncookies.c                  |    1 +
 net/ipv4/sysctl_net_ipv4.c             |   45 ++++++
 net/ipv4/tcp.c                         |   49 +++++-
 net/ipv4/tcp_fastopen.c                |   83 ++++++++++-
 net/ipv4/tcp_input.c                   |   75 +++++++--
 net/ipv4/tcp_ipv4.c                    |  269 ++++++++++++++++++++++++++++++--
 net/ipv4/tcp_minisocks.c               |   61 ++++++--
 net/ipv4/tcp_output.c                  |   21 ++-
 net/ipv4/tcp_timer.c                   |   39 +++++-
 net/ipv6/syncookies.c                  |    1 +
 net/ipv6/tcp_ipv6.c                    |    5 +-
 20 files changed, 915 insertions(+), 97 deletions(-)

-- 
1.7.7.3
