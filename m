From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/2] fix udp pull header breakage
Date: Thu,  7 Apr 2016 11:44:57 -0400
Message-ID: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fcooper@ti.com, samanthakumar@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:34611 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756552AbcDGPpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:45:04 -0400
Received: by mail-qg0-f66.google.com with SMTP id j35so7586968qge.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:45:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Commit e6afc8ace6dd ("udp: remove headers from UDP packets before
queueing") modified udp receive processing to pull headers before
enqueue and to not expect them on dequeue.

The patch missed protocols on top of udp with in-kernel
implementations that have their own skb_recv_datagram calls and
dequeue logic. Modify these datapaths to also no longer expect
a udp header at skb->data.

Sunrpc and rxrpc are the only two protocols that call this
function and contain references to udphr (some others, like tipc,
are based on encap_rcv, which acts before enqueue, before the
the header pull).

Willem de Bruijn (2):
  sunrpc: do not pull udp headers on receive
  rxrpc: do not pull udp headers on receive

 net/rxrpc/ar-input.c  | 4 ++--
 net/sunrpc/socklib.c  | 2 +-
 net/sunrpc/svcsock.c  | 5 ++---
 net/sunrpc/xprtsock.c | 5 ++---
 4 files changed, 7 insertions(+), 9 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
