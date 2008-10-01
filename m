From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 01 Oct 2008 09:03:50 -0700 (PDT)
Message-ID: <20081001.090350.193699565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbYJAQEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:04:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) tcp_v4_send_ack() and tcp_v6_send_ack() can derference
   a NULL skb->dev in certain circumstances with namespaces
   enabled.

   Fix from Denis V. Lunev and Vitaliy Gusev

2) ip6_dst_blackhole_ops has a NULL kmem_cachep field leading
   to OOPS with blackhole routes.  Fix from Arnaud Ebalard.

3) If the AF_KEY socket is closed in the middle of an IPSEC
   rule dump, we leak rules.

   Fix from Timo Teras.

4) SCTP crash fix in protocol violation parameter processing,
   this is probably triggerable remotely.

   Fix from Wei Yongjun.

5) Fix an IUCV protocol mismserge in 2.6.27, this was causing
   scheduling in interrupt problems and other nasties.

   Fix from Heiko Carstens.

Please pull, thanks a lot!

The following changes since commit 94aca1dac6f6d21f4b07e4864baf7768cabcc6e7:
  Linus Torvalds (1):
        Linux 2.6.27-rc8

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Arnaud Ebalard (1):
      XFRM,IPv6: initialize ip6_dst_blackhole_ops.kmem_cachep

Denis V. Lunev (1):
      ipv6: NULL pointer dereferrence in tcp_v6_send_ack

Heiko Carstens (1):
      iucv: Fix mismerge again.

Herbert Xu (1):
      ipsec: Fix pskb_expand_head corruption in xfrm_state_check_space

Timo Teras (1):
      af_key: Free dumping state on socket close

Vitaliy Gusev (1):
      tcp: Fix NULL dereference in tcp_4_send_ack()

Wei Yongjun (1):
      sctp: Fix kernel panic while process protocol violation parameter

 include/net/sctp/sm.h    |    3 ++
 net/ipv4/tcp_ipv4.c      |    2 +-
 net/ipv6/route.c         |    2 +
 net/ipv6/tcp_ipv6.c      |    2 +-
 net/iucv/iucv.c          |    3 +-
 net/key/af_key.c         |   30 ++++++++++++++++++----------
 net/sctp/sm_make_chunk.c |   37 +++++++++++++++++++++++------------
 net/sctp/sm_statefuns.c  |   48 +++++++++++++++++++++++++++++++++++----------
 net/xfrm/xfrm_output.c   |   12 +++++++---
 9 files changed, 97 insertions(+), 42 deletions(-)
