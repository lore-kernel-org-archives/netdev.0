From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next 0/2] tcp: reduce cpu usage when SO_SNDBUF is set
Date: Wed, 22 Jun 2016 11:32:49 -0400
Message-ID: <cover.1466608332.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:52659 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751601AbcFVPfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 11:35:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've added a patch to upgrade smp_mb__after_atomic() to a smp_mb()
as Eric Dumazet pointed out. Also combined the clearing of
SOCK_SHORT_WRITE with SOCK_QUEUE_SHRUNK.

Thanks,

-Jason

v2:
-upgrade smp_mb__after_atomic to smp_mb() in tcp_poll()
-combine clear of SOCK_SHORT_WRITE with SOCK_QUEUE_SHRUNK

Jason Baron (2):
  tcp: replace smp_mb__after_atomic() with smp_mb() in tcp_poll()
  tcp: reduce cpu usage when SO_SNDBUF is set

 include/net/sock.h   |  6 ++++++
 net/ipv4/tcp.c       | 26 +++++++++++++++++++-------
 net/ipv4/tcp_input.c |  5 +++--
 3 files changed, 28 insertions(+), 9 deletions(-)

-- 
2.6.1
