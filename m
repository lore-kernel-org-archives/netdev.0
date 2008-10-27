From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 26 Oct 2008 23:26:26 -0700 (PDT)
Message-ID: <20081026.232626.97216182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbYJ0G0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 02:26:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several bug fixes:

1) Skb ->when timestamp setting for syncookies got messed up
   by TCP option building engine changes in 2.6.27.  Fix from
   Florian Westphal

   I'll submit this thusly to -stable as well.

2) Couple places trying to pass sk_buff to kfree() instead of
   kfree_skb().  Fixed by Sergio Luis

3) Two fixes for the new phonet protocol layer from Remi
   Denis-Courmont

Please pull, thanks a lot.

The following changes since commit f8d56f1771e4867acc461146764b4feeb5245669:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://neil.brown.name/md

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Florian Westphal (1):
      syncookies: fix inclusion of tcp options in syn-ack

Remi Denis-Courmont (2):
      Phonet: include generic link-layer header size in MAX_PHONET_HEADER
      Phonet: do not reply to indication reset packets

Sergio Luis (2):
      btsdio: free sk_buff with kfree_skb
      libertas: free sk_buff with kfree_skb

 drivers/bluetooth/btsdio.c         |    2 +-
 drivers/net/wireless/libertas/rx.c |    2 +-
 include/linux/phonet.h             |    1 +
 include/net/phonet/phonet.h        |    2 +-
 net/ipv4/tcp_output.c              |   10 +++++-----
 net/phonet/af_phonet.c             |    5 ++++-
 6 files changed, 13 insertions(+), 9 deletions(-)
