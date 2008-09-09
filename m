From: David Miller <davem@davemloft.net>
Subject: [GIT]: Netwokring
Date: Tue, 09 Sep 2008 16:16:49 -0700 (PDT)
Message-ID: <20080909.161649.255531084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39147
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750921AbYIIXQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 19:16:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Three bluetooth regression fixes from Marcel Holtmann.

2) In 2.6.27 we added a faster and more reliable IPSEC policy and
   state dumping mechanism, but this new code leaves out larval and
   socket local policies which is an unintended user visible change.

   Fixed by Herbert Xu.

3) As per kernel bugzilla, ip6_dst_lookup_tail() can OOPS when the
   optimistic DAD config option is enabled because said code assumes
   there is always a neighbour attached to a route at this point,
   but that is not necessarily true.

   Thanks to analysis by Eveniy Polyakov and final patch by Neil
   Horman who wrote the optimistic DAD bits.

Please pull, thanks a lot.

The following changes since commit 82a28c794f27aac17d7a3ebd7f14d731a11a5532:
  Linus Torvalds (1):
        Merge branch 'master' of git://git.kernel.org/.../hskinnemoen/avr32-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Herbert Xu (1):
      ipsec: Restore larval states and socket policies in dump

Marcel Holtmann (3):
      [Bluetooth] Fix reference counting during ACL config stage
      [Bluetooth] Enforce correct authentication requirements
      [Bluetooth] Reject L2CAP connections on an insecure ACL link

Neil Horman (1):
      ipv6: Fix OOPS in ip6_dst_lookup_tail().

 include/net/bluetooth/hci_core.h |    3 +-
 net/bluetooth/af_bluetooth.c     |    2 +-
 net/bluetooth/hci_conn.c         |   21 ++++++++++--
 net/bluetooth/hci_event.c        |   11 ++----
 net/bluetooth/l2cap.c            |   34 ++++++++++++++++---
 net/bluetooth/sco.c              |    2 +-
 net/ipv6/ip6_output.c            |   64 +++++++++++++++++++-------------------
 net/xfrm/xfrm_policy.c           |    1 +
 net/xfrm/xfrm_state.c            |    2 +
 9 files changed, 89 insertions(+), 51 deletions(-)

