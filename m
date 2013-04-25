From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 0/4] sock_diag: monitor packet sockets
Date: Thu, 25 Apr 2013 15:21:47 +0200
Message-ID: <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56285 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657Ab3DYNV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:21:59 -0400
In-Reply-To: <20130425.050008.2129680886418162075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patchset is to be able to monitor packet sockets.
The two first patches add new attributes for packet_diag subsystem, so that all
information exported via the /proc/net/packet are also exported via netlink.
The third patch avoid to disclose socket pointer to all user. Via the /proc,
kptr_restrict is used.
The last patch allows allowed users to get details about filter attached to a
packet socket.

As usual, the patch against iproute2 will be sent once the patches are included
and net-next merged. I can send it on demand.

v2: add sock_diag_notify_del() to avoid confusion of the meaning of the second
    arg of __sock_diag_notify()
    enhance commitlog of patch 3/5

v3: drop previous 4/5 and 5/5 patches
    add patch 3/4 (sock_diag: do not disclose sock ptr to all users)
    disclose filters only to allowed users

 include/linux/sock_diag.h        |  5 ++++-
 include/uapi/linux/packet_diag.h |  5 +++++
 net/core/sock_diag.c             | 45 +++++++++++++++++++++++++++++++++++++---
 net/ipv4/inet_diag.c             | 13 +++++++-----
 net/netlink/diag.c               |  5 ++++-
 net/packet/diag.c                | 29 ++++++++++++++++++++------
 net/unix/diag.c                  | 14 ++++++++-----
 7 files changed, 95 insertions(+), 21 deletions(-)

Comments are welcome.

Regards,
Nicolas
