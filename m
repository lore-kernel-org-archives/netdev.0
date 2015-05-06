From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 0/7] packet: refine rollover
Date: Wed,  6 May 2015 14:27:10 -0400
Message-ID: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:33446 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFS1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:21 -0400
Received: by yhcb70 with SMTP id b70so4723964yhc.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Refine packet socket rollover:

1. mitigate a case of lock contention
2. avoid resource exhaustion on other sockets,
   by migrating only to a victim socket that has ample room
3. avoid reordering other flows on the same socket,
   by migrating first the flow responsible for load imbalance
4. help processes detect load imbalance,
   by exporting rollover counters

Context: rollover implements flow migration in packet socket fanout
groups in case of extreme load imbalance. It is a specific
implementation of migration that minimizes reordering by selecting
the same victim socket when possible (and by selecting subsequent
victims in a round robin fashion, from which its name derives).

Willem de Bruijn (7):
  packet: rollover prepare: move code out of callsites
  packet: rollover prepare: per-socket state
  packet: rollover prepare: single return in packet_rcv_has_room
  packet: rollover lock contention avoidance
  packet: rollover only to socket with headroom
  packet: rollover huge flows before small flows
  packet: rollover statistics

 include/uapi/linux/if_packet.h |   7 ++
 net/packet/af_packet.c         | 164 ++++++++++++++++++++++++++++++++++-------
 net/packet/internal.h          |  14 +++-
 3 files changed, 157 insertions(+), 28 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
