From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/6] tcp: congestion control refactoring
Date: Thu, 14 Jan 2016 15:43:28 -0800
Message-ID: <1452815014-601-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33724 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855AbcANXoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:44:14 -0500
Received: by mail-pf0-f170.google.com with SMTP id e65so107789442pfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 15:44:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set refactors the sequence of congestion control,
loss recovery, and transmission logic in TCP ack processing.

The design goal is to decouple and sequence them in the following order:

  0. ACK accounting: free or tag sent packets [unchanged]

  1. loss recovery: identify lost/ecn packets and update congestion state

  2. congestion control: up/down cwnd and pacing rate based on (1)

  3. transmission: send new or retransmit old based on (1) and (2)

This refactoring makes the cwnd changes more clear because it's done
in one place. The packet accounting is also more robust especially
for connections that do not support SACK. Patch 1-4 and 6 are
refactoring and patch 5 improves TCP performance under reordering.

Yuchung Cheng (6):
  tcp: retransmit after recovery processing and congestion control
  tcp: move cwnd reduction after recovery state procesing
  tcp: new delivery accounting
  tcp: refactor pkts acked accounting
  tcp: make congestioin control more robust against reordering
  tcp: tcp_cong_control helper

 include/linux/tcp.h  |   1 +
 net/ipv4/tcp_input.c | 147 +++++++++++++++++++++++++++++++++------------------
 2 files changed, 96 insertions(+), 52 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
