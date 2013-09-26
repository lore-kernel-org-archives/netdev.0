From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Introduce support to lazy initialize mostly static keys
Date: Fri, 27 Sep 2013 01:32:16 +0200
Message-ID: <1380238343-4318-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53989 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab3IZXc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 19:32:29 -0400
Received: from kernel.localhost (localhost.localdomain [127.0.0.1])
	by order.stressinduktion.org (Postfix) with ESMTP id A4A211A0C242
	for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 01:32:28 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series implements support for delaying the initialization of secret
keys, e.g. used for hashing, for as long as possible. This functionality
is implemented by a new macro, net_get_random_bytes.

I already used it to protect the socket hashes, the syncookie secret
(most important) and the tcp_fastopen secrets.

This series depends on a patch from Eric Dumazet (already in patchworks):
"net: net_secret should not depend on TCP"

Included patches:
  ipv4: split inet_ehashfn to one hash
  ipv6: split inet6_ehashfn to one hash
  net: introduce new macro net_get_random_once
  inet: split syncookie keys for ipv4 and ipv6 and
  inet: convert inet_ehash_secret and
  tcp: switch tcp_fastopen key generation to
  net: switch net_secret key generation to

Diffstat:
 include/linux/net.h            |   14 ++++++++++++++
 include/net/inet6_hashtables.h |   29 +++++++----------------------
 include/net/inet_sock.h        |   26 ++++++--------------------
 include/net/ipv6.h             |    4 ++--
 include/net/tcp.h              |    3 +--
 net/core/secure_seq.c          |   14 ++------------
 net/core/utils.c               |   21 +++++++++++++++++++++
 net/ipv4/af_inet.c             |   27 ---------------------------
 net/ipv4/inet_hashtables.c     |   25 +++++++++++++++++++++++++
 net/ipv4/syncookies.c          |   15 +++++----------
 net/ipv4/sysctl_net_ipv4.c     |    5 +++++
 net/ipv4/tcp_fastopen.c        |   21 ++++++++++-----------
 net/ipv4/udp.c                 |   22 +++++++++++++++++-----
 net/ipv6/af_inet6.c            |    5 -----
 net/ipv6/inet6_hashtables.c    |   40 +++++++++++++++++++++++++++++++++++++---
 net/ipv6/syncookies.c          |   12 +++++++++---
 net/ipv6/udp.c                 |   37 ++++++++++++++++++++++++++++++-------
 net/rds/connection.c           |   18 ++++++++++++------
 18 files changed, 203 insertions(+), 135 deletions(-)


Greetings,

  Hannes
