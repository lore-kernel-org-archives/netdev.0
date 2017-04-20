From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH netnext 0/3] packet: Add option to create new fanout group with unique id.
Date: Thu, 20 Apr 2017 15:25:43 -0400
Message-ID: <20170420192546.5567-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:32807 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947029AbdDTT0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:26:07 -0400
Received: by mail-yw0-f196.google.com with SMTP id 203so6486992ywe.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:26:01 -0700 (PDT)
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
