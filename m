From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/3] packet: Add option to create new fanout group with unique id.
Date: Fri, 21 Apr 2017 10:56:09 -0400
Message-ID: <20170421145612.106869-1-willemdebruijn.kernel@gmail.com>
Cc: maloneykernel@gmail.com, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35545 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041602AbdDUSnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:43:42 -0400
Received: by mail-qk0-f194.google.com with SMTP id k139so13451622qke.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:43:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Fanout uses a per net global namespace. A process that intends to create a
new fanout group can accidentally join an existing group. It is
not possible to detect this.

Add a socket option to specify on the first call to
setsockopt(..., PACKET_FANOUT, ...) to ensure that a new group is created.
Also add tests.

Mike Maloney (3):
  selftests/net: cleanup unused parameter in psock_fanout
  packet: add PACKET_FANOUT_FLAG_UNIQUEID to assign new fanout group id.
  selftests/net: add tests for PACKET_FANOUT_FLAG_UNIQUEID

 include/uapi/linux/if_packet.h             |  1 +
 net/packet/af_packet.c                     | 44 ++++++++++++++
 tools/testing/selftests/net/psock_fanout.c | 93 ++++++++++++++++++++++++++----
 3 files changed, 128 insertions(+), 10 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
