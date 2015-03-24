From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/5] tcp: listener refactor part 16
Date: Tue, 24 Mar 2015 15:58:51 -0700
Message-ID: <1427237936-19030-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:34543 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbbCXW7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:59:09 -0400
Received: by obcwp18 with SMTP id wp18so616260obc.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:59:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A CONFIG_PROVE_RCU=y build revealed an RCU splat I had to fix.

I added const qualifiers to various md5 methods, as I expect
to call them on behalf of request sock traffic even if
the listener socket is not locked. This seems ok, but adding
const makes the contract clearer. Note a good reduction
of code size thanks to request/establish sockets convergence.

Eric Dumazet (5):
  tcp: md5: fix rcu lockdep splat
  tcp: use C99 initializers in new_state[]
  tcp: md5: input path is run under rcu protected sections
  tcp: md5: remove request sock argument of calc_md5_hash()
  tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()

 include/net/tcp.h     | 37 +++++++++++++++++------------------
 net/ipv4/tcp.c        | 25 ++++++++++++------------
 net/ipv4/tcp_ipv4.c   | 53 +++++++++++++++------------------------------------
 net/ipv4/tcp_output.c | 24 ++++++++++++-----------
 net/ipv6/tcp_ipv6.c   | 50 ++++++++++++++----------------------------------
 5 files changed, 72 insertions(+), 117 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
