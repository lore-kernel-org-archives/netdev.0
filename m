From: Craig Gallek <kraig@google.com>
Subject: [PATCH net-next 0/3] Socket destruction events via netlink sock_diag
Date: Mon, 15 Jun 2015 11:26:17 -0400
Message-ID: <1434381980-20588-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:33670 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbbFOP1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:27:12 -0400
Received: by yhpn97 with SMTP id n97so45036088yhp.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:27:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series extends the netlink sock_diag interface to broadcast
socket information as they are being destroyed.  The current
interface is poll based and can not be used to retreive information
about sockets that are destroyed between poll intervals.

Only inet sockets are broadcast in this implementation, but other
families could easily be added as needed in the future.

If this patch set is accepted, a follow-up patch to the ss utility
in the iproute2 suite will also be submitted.

Craig Gallek (3):
  sock_diag: define destruction multicast groups
  sock_diag: specify info_size per inet protocol
  sock_diag: implement a get_info handler for inet

 include/linux/inet_diag.h      |  1 +
 include/linux/sock_diag.h      | 42 +++++++++++++++++++++
 include/net/sock.h             |  1 +
 include/uapi/linux/inet_diag.h |  3 +-
 include/uapi/linux/sock_diag.h | 10 +++++
 net/core/sock.c                | 11 +++++-
 net/core/sock_diag.c           | 85 ++++++++++++++++++++++++++++++++++++++++++
 net/dccp/diag.c                |  1 +
 net/ipv4/inet_diag.c           | 50 ++++++++++++++++++++++++-
 net/ipv4/tcp.c                 |  4 +-
 net/ipv4/tcp_diag.c            |  6 ++-
 net/ipv4/udp_diag.c            |  2 +
 12 files changed, 209 insertions(+), 7 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
