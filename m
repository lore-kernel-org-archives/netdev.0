From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/6] tcp: congestion control refactoring
Date: Tue,  2 Feb 2016 10:33:03 -0800
Message-ID: <1454437989-3842-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35398 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933687AbcBBSdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:33:33 -0500
Received: by mail-pf0-f178.google.com with SMTP id 65so109427140pfd.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 10:33:33 -0800 (PST)
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
  tcp: make congestion control more robust against reordering
  tcp: tcp_cong_control helper

 include/linux/tcp.h  |   1 +
 net/ipv4/tcp_input.c | 149 +++++++++++++++++++++++++++++++++------------------
 2 files changed, 98 insertions(+), 52 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
