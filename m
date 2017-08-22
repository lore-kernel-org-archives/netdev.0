From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH v2 net-next 0/2] Add software rx timestamp for TCP.
Date: Tue, 22 Aug 2017 17:08:47 -0400
Message-ID: <20170822210849.23162-1-maloneykernel@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, soheil@google.com,
        Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36597 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752407AbdHVVJG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:09:06 -0400
Received: by mail-yw0-f195.google.com with SMTP id s187so3121147ywf.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 14:09:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Add software rx timestamps for TCP, and a test to ensure consistency of
behavior between IP, UDP, and TCP implementation.

Changes since v1:
  -Initialize tss->ts[1] to 0 if caller requested any timestamps.
  -Fix test case to validate that tss->ts[1] is zero.
  -Fix tests to actually use a raw socket.
  -Fix --tcp flag to work on the test.

Mike Maloney (2):
  tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE to TCP recvmsg
  selftests/net: Add a test to validate behavior of rx timestamps

 include/net/tcp.h                                  |   9 +-
 net/ipv4/tcp.c                                     |  65 ++++
 net/ipv4/tcp_input.c                               |  35 +-
 net/ipv4/tcp_ipv4.c                                |   2 +
 net/ipv6/tcp_ipv6.c                                |   2 +
 .../selftests/networking/timestamping/.gitignore   |   1 +
 .../selftests/networking/timestamping/Makefile     |   4 +-
 .../networking/timestamping/rxtimestamp.c          | 389 +++++++++++++++++++++
 8 files changed, 501 insertions(+), 6 deletions(-)
 create mode 100644 tools/testing/selftests/networking/timestamping/rxtimestamp.c

-- 
2.14.1.480.gb18f417b89-goog
