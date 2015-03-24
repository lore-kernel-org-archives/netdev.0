From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] tcp: listener refactor part 16
Date: Mon, 23 Mar 2015 21:34:22 -0700
Message-ID: <1427171666-30585-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:32992 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbCXEe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 00:34:29 -0400
Received: by oiba3 with SMTP id a3so11993291oib.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 21:34:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I added const qualifiers to various md5 methods, as I expect
to call them on behalf of request sock traffic even if
the listener socket is not locked. This seems ok, but adding
const makes the contract clearer. Note a good reduction
of code size thanks to request/establish sockets convergence.

Eric Dumazet (4):
  tcp: use C99 initializers in new_state[]
  tcp: md5: input path is run under rcu protected sections
  tcp: md5: remove request sock argument of calc_md5_hash()
  tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()

 include/net/tcp.h     | 45 +++++++++++++++++++---------------------
 net/ipv4/tcp.c        | 25 +++++++++++-----------
 net/ipv4/tcp_ipv4.c   | 57 +++++++++++++++------------------------------------
 net/ipv4/tcp_output.c |  6 +++---
 net/ipv6/tcp_ipv6.c   | 56 +++++++++++++++-----------------------------------
 5 files changed, 71 insertions(+), 118 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
