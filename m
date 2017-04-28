From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 28 Apr 2017 16:16:41 -0400 (EDT)
Message-ID: <20170428.161641.1172173067464086629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756911AbdD1UQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just a couple more stragglers, I really hope this is it:

1) Don't let frags slip down into the GRO segmentation handlers,
   from Steffen Klassert.

2) Truesize under-estimation triggers warnings in TCP over loopback
   with socket filters, 2 part fix from Eric Dumazet.

3) Fix undesirable reset of bonding MTU to ETH_HLEN on slave removal,
   from Paolo Abeni.

4) If we flush the XFRM policy after garbage collection, it doesn't
   work because stray entries can be created afterwards.  Fix from
   Xin Long.

5) Hung socket connection fixes in TIPC from Parthasarathy Bhuvaragan.

6) Fix GRO regression with IPSEC when netfilter is disabled, from
   Sabrina Dubroca.

7) Fix cpsw driver Kconfig dependency regression, from Arnd Bergmann.

Please pull, thanks a lot.

The following changes since commit f83246089ca09308425175d47f5e71e6da68b2ef:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2017-04-26 15:10:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 4c761daf8bb9a2cbda9facf53ea85d9061f4281e:

  net: hso: register netdev later to avoid a race condition (2017-04-28 16:11:48 -0400)

----------------------------------------------------------------
Andreas Kemnade (1):
      net: hso: register netdev later to avoid a race condition

Arnd Bergmann (1):
      cpsw/netcp: refine cpts dependency

David S. Miller (2):
      Merge branch 'tipc-socket-connection-hangs'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec

Eric Dumazet (2):
      tcp: do not underestimate skb->truesize in tcp_trim_head()
      net: adjust skb->truesize in ___pskb_trim()

Paolo Abeni (1):
      bonding: avoid defaulting hard_header_len to ETH_HLEN on slave removal

Parthasarathy Bhuvaragan (3):
      tipc: Fix missing connection request handling
      tipc: improve error validations for sockets in CONNECTING state
      tipc: close the connection if protocol messages contain errors

Sabrina Dubroca (1):
      xfrm: fix GRO for !CONFIG_NETFILTER

Steffen Klassert (1):
      ipv4: Don't pass IP fragments to upper layer GRO handlers.

Xin Long (1):
      xfrm: do the garbage collection after flushing policy

 drivers/net/bonding/bond_main.c |  2 +-
 drivers/net/ethernet/ti/Kconfig |  4 +++-
 drivers/net/usb/hso.c           | 14 +++++++-------
 net/core/skbuff.c               |  2 ++
 net/ipv4/af_inet.c              |  3 +++
 net/ipv4/tcp_output.c           | 19 ++++++++++++-------
 net/tipc/socket.c               | 36 +++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_input.c           |  2 +-
 net/xfrm/xfrm_policy.c          |  4 ++++
 9 files changed, 64 insertions(+), 22 deletions(-)
