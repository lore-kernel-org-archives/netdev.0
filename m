From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc 0/4] timestamping updates
Date: Tue, 25 Nov 2014 12:58:02 -0500
Message-ID: <1416938286-14147-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:62340 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYR6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:58:10 -0500
Received: by mail-yh0-f54.google.com with SMTP id 29so567866yhl.13
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:58:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The main goal for this patchset is to allow correlating timestamps
with the egress interface. That change requires a few others:

1/4: TCP sockets should not loop L2/L3/L4 headers
2/4: main feature
3/4: bugfix: TCP sockets should call the family specific .._recv_error
4/4: revise the test to verify these changes

Willem de Bruijn (4):
  net-timestamp: pull headers for SOCK_STREAM
  net-errqueue: add IP(V6)_PKTINFO support
  net-timestamp: tcp sockets return v6 errors on v6 sockets
  net-timestamp: expand txtimestamp test with payload and PKTINFO

 .../networking/timestamping/txtimestamp.c          | 89 +++++++++++++++++++---
 net/core/skbuff.c                                  |  6 +-
 net/ipv4/ip_sockglue.c                             | 15 ++++
 net/ipv4/tcp.c                                     |  8 +-
 net/ipv6/datagram.c                                | 22 ++++++
 5 files changed, 125 insertions(+), 15 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
