From: Jiri Olsa <jolsa@redhat.com>
Subject: [PATCH 0/2] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 16:04:34 +0200
Message-ID: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46111 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbZF2OEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 10:04:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset fixies the race within the poll_wait call and the receive callbacks,
by adding memory barrier.

- 1/2 includes the actual fix
- 2/2 includes optimization for the x86 arch

It is discussed and described in the following discussions:

http://lkml.org/lkml/2009/6/18/124
http://lkml.org/lkml/2009/6/25/188

Patchset is made on top of Linus'es tree 52989765629e7d182b4f146050ebba0abf2cb0b7.

wbr,
jirka

---
 arch/x86/include/asm/spinlock.h |    3 ++
 include/linux/poll.h            |   11 ++++++++-
 include/linux/spinlock.h        |    5 ++++
 include/net/sock.h              |   40 +++++++++++++++++++++++++++++++++++++++
 net/atm/common.c                |    6 ++--
 net/core/datagram.c             |    2 +-
 net/core/sock.c                 |    8 +++---
 net/dccp/output.c               |    2 +-
 net/dccp/proto.c                |    2 +-
 net/ipv4/tcp.c                  |    2 +-
 net/iucv/af_iucv.c              |    4 +-
 net/rxrpc/af_rxrpc.c            |    4 +-
 net/unix/af_unix.c              |    8 +++---
 13 files changed, 76 insertions(+), 21 deletions(-)
