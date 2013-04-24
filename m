From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 0/5] sock_diag: monitor packet sockets
Date: Wed, 24 Apr 2013 17:52:31 +0200
Message-ID: <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
References: <51779426.7020800@6wind.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54883 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382Ab3DXPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 11:53:16 -0400
In-Reply-To: <51779426.7020800@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patchset is to be able to monitor packet sockets.
The two first patches add new attributes for packet_diag subsystem, so that all
information exported via the /proc/net/packet are also exported via netlink.
The third patch allows the user to get details about filter attached to a packet
socket.
Then, the two last one enable sockets monitoring. A netlink message is sent each
time a packet socket is created, deleted or when the filter information are
updated.

As usual, the patch against iproute2 will be sent once the patches are included
and net-next merged. I can send it on demand.
With this serie, the tools ss can monitor packet sockets activity.

v2: add sock_diag_notify_del() to avoid confusion of the meaning of the second
    arg of __sock_diag_notify()
    enhance commitlog of patch 3/5

 include/linux/sock_diag.h        |  6 ++++
 include/uapi/linux/packet_diag.h |  5 +++
 include/uapi/linux/sock_diag.h   | 13 +++++++-
 net/core/filter.c                |  3 ++
 net/core/sock_diag.c             | 68 ++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c           |  4 +++
 net/packet/diag.c                | 49 +++++++++++++++++++++++++----
 7 files changed, 141 insertions(+), 7 deletions(-)

Comments are welcome.

Regards,
Nicolas
