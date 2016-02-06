From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] tcp/dccp: better use of ephemeral ports
Date: Fri,  5 Feb 2016 18:08:56 -0800
Message-ID: <1454724538-13556-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34031 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFCJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 21:09:04 -0500
Received: by mail-pf0-f175.google.com with SMTP id o185so77971097pfb.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 18:09:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Big servers have bloated bind table, making very hard to succeed
ephemeral port allocations, without special containers/namespace tricks.

This patch series extends the strategy added in commit 07f4c90062f8 
("tcp/dccp: try to not exhaust ip_local_port_range in connect()").

Since ports used by connect() are much likely to be shared among them,
we give a hint to both bind() and connect() to keep the crowds separated
if possible.

Of course, if on a specific host an application needs to allocate ~30000
ports using bind(), it will still be able to do so. Same for ~30000 connect()
to a unique 2-tuple (dst addr, dst port)

New implemetation is also more friendly to softirqs and reschedules.

Eric Dumazet (2):
  tcp/dccp: better use of ephemeral ports in connect()
  tcp/dccp: better use of ephemeral ports in bind()

 net/ipv4/inet_connection_sock.c | 231 +++++++++++++++++++---------------------
 net/ipv4/inet_hashtables.c      | 170 ++++++++++++++---------------
 2 files changed, 195 insertions(+), 206 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
