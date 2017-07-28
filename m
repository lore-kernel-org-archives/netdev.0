From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 0/3] net: Infrastructure changes for [kz]proxy
Date: Fri, 28 Jul 2017 16:22:40 -0700
Message-ID: <20170728232243.3040-1-tom@quantonium.net>
Cc: rohit@quantonium.net, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35915 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdG1XXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 19:23:10 -0400
Received: by mail-pf0-f175.google.com with SMTP id z129so61339714pfb.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 16:23:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains some general infrastructure enhancements that
will be used by kernel proxy and zero proxy.

The changes are:
  - proto_ops: Add locked versions of sendmsg and sendpage
  - skb_send_sock: Allow sending and skb on a socket within the
    kernel
  - Generalize strparser. Allow it to be used in other contexts than
    just in the read_sock path. This will be used in the transmit
    path of zero proxy.

Some nice future work (which I've been discussing with John Fastabend)
will be to make some of the related functions to allow gifting of skbs
We should be able to do that with skb_send_sock and strp_process. I'd
also like this feature in the read_sock callbeck.

Tested: Ran modified kernel without incident. Tested new functionality
using zero proxy (in development).


Tom Herbert (3):
  proto_ops: Add locked held versions of sendmsg and sendpage
  skbuff: Function to send an skbuf on a socket
  strparser: Generalize strparser

 Documentation/networking/strparser.txt | 207 +++++++++++++++-------
 include/linux/net.h                    |  12 ++
 include/linux/skbuff.h                 |   3 +
 include/net/sock.h                     |   3 +
 include/net/strparser.h                | 119 +++++++------
 include/net/tcp.h                      |   3 +
 net/core/skbuff.c                      | 101 +++++++++++
 net/core/sock.c                        |  22 +++
 net/ipv4/af_inet.c                     |   2 +
 net/ipv4/tcp.c                         |  39 ++--
 net/kcm/kcmproc.c                      |  34 ++--
 net/kcm/kcmsock.c                      |  38 ++--
 net/socket.c                           |  27 +++
 net/strparser/strparser.c              | 313 ++++++++++++++++++++-------------
 14 files changed, 623 insertions(+), 300 deletions(-)

-- 
2.11.0
