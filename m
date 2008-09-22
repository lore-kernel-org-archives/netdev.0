From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 22 Sep 2008 05:21:11 -0700 (PDT)
Message-ID: <20080922.052111.260555210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751669AbYIVMVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 08:21:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just one regression fix here.

When we are doing multiqueue TX, we accidently try to fetch the
protocol inside of IP fragments when computing the hash.

This completely kills performance since what we use for the ports is
essentially random garbage, and as a result this causes lots of packet
reordering and other nasties.

For drivers that have TX multiqueue support, this creates a serious
performance regression against 2.6.26

I know of at least one piece of hardware which has this same bug in
it's silicon for doing RX multiqueue hashing :-)

Noticed and fixed by Alexander Duyck.

Please pull, thanks a lot!

The following changes since commit e7272403d2f9be3dbb7cc185fcc390e781b1af6b:
  Rafael J. Wysocki (1):
        e100: Use pci_pme_active to clear PME_Status and disable PME#

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      netdev: simple_tx_hash shouldn't hash inside fragments

 net/core/dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)
