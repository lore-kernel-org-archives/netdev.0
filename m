From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [RFC PATCH 0/4] inet: add second hash table
Date: Wed, 30 May 2012 10:36:46 +0300
Message-ID: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60430 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2E3Hix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:38:53 -0400
Received: by wgbdr13 with SMTP id dr13so4725525wgb.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:38:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements all the operations needed to use a second
(port,address) bind hash table for inet. It uses a similar approach
as the UDP implementation.

The performance improvements for port allocation are very good and
detailed in the last message.

This is based on a series of patches written by Lucian Grijincu at Ixia.

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
---
Alexandru Copot (4):
      inet: add counter to inet_bind_hashbucket
      inet: add a second bind hash
      inet: add/remove inet buckets in the second bind hash
      inet: use second hash in inet_csk_get_port

 include/net/inet_hashtables.h    |  140 +++++++++++++++++++++++++++++++--
 include/net/inet_timewait_sock.h |    5 +-
 net/dccp/proto.c                 |   37 ++++++++-
 net/ipv4/inet_connection_sock.c  |   66 ++++++++--------
 net/ipv4/inet_hashtables.c       |  158 ++++++++++++++++++++++++++++++++++++--
 net/ipv4/inet_timewait_sock.c    |   16 ++--
 net/ipv4/tcp.c                   |   17 ++++
 net/ipv6/inet6_hashtables.c      |   95 +++++++++++++++++++++++
 8 files changed, 477 insertions(+), 57 deletions(-)
