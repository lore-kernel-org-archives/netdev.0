From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/2] tcp: more reliable window probes
Date: Wed,  6 May 2015 14:26:23 -0700
Message-ID: <1430947585-2375-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:34216 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbEFV0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:26:34 -0400
Received: by igdh15 with SMTP id h15so1960849igd.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 14:26:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series address a problem caused by small rto_min timers in DC,
leading to either timer storms or early flow terminations.

We also add two new SNMP counters for proper monitoring :
TCPWinProbe and TCPKeepAlive

v2: added TCPKeepAlive counter, as suggested by Yuchung & Neal

Eric Dumazet (2):
  tcp: adjust window probe timers to safer values
  tcp:  tcp: add TCPWinProbe and TCPKeepAlive SNMP counters

 include/net/tcp.h         | 27 ++++++++++++++++++++++-----
 include/uapi/linux/snmp.h |  1 +
 net/ipv4/proc.c           |  1 +
 net/ipv4/tcp_input.c      |  2 +-
 net/ipv4/tcp_output.c     |  3 ++-
 5 files changed, 27 insertions(+), 7 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
