From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v3 0/9] forcedeth: stats & debug enhancements
Date: Mon, 14 Nov 2011 16:11:10 -0800
Message-ID: <cover.1321313729.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:61253 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab1KOALb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 19:11:31 -0500
Received: by faap16 with SMTP id p16so83886faa.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 16:11:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes implement the ndo_get_stats64 API and add a few more
stats and debugging features for forcedeth. They also ensure that
stats updates are correct in SMP systems, 32 or 64-bits.

Changes since v2:
  - patch 1/9 is the cherry-pick of 898bdf2cb43e ("forcedeth: fix
    stats on hardware without extended stats support")
  - removed patch 5/10 "stats for rx_packets based on hardware
    registers" because packets&bytes stats are updated in software
    only (898bdf2cb43e)

Changes since v1:
  - patch 1/10 is the same as
    http://patchwork.ozlabs.org/patch/125017/ (targetting net)
  - other patches updated to take patch 1/10 into account
  - various commit message updates


Tested:
  ~150Mbps incoming TCP, ethtool -S in a loop, x86_64 16-way:
     tx_bytes: 5441989419
     rx_packets: 5439224
     tx_timeout: 0
     tx_packets: 5456705
     rx_bytes: 5566763850

Tested:
  pktgen + loopback report same RX/TX packets and bytes stats

Tested:
  tests above with Kconfig DEBUG_PAGEALLOC DEBUG_MUTEXES
  DEBUG_SPINLOCK LOCKUP_DETECTOR DEBUG_RT_MUTEXES DEBUG_LOCK_ALLOC
  PROVE_LOCKING DEBUG_ATOMIC_SLEEP DEBUG_STACK_USAGE DEBUG_KOBJECT
  DEBUG_VM DEBUG_LIST DEBUG_SG DEBUG_NOTIFIERS TEST_KSTRTOX
  STRICT_DEVMEM DEBUG_STACKOVERFLOW


############################################
# Patch Set Summary:

David Decotigny (6):
  forcedeth: expose module parameters in /sys/module
  forcedeth: implement ndo_get_stats64() API
  forcedeth: account for dropped RX frames
  forcedeth: new ethtool stat counter for TX timeouts
  forcedeth: stats updated with a deferrable timer
  forcedeth: whitespace/indentation fixes

Mike Ditto (1):
  forcedeth: Add messages to indicate using MSI or MSI-X

Sameer Nanda (1):
  forcedeth: allow to silence "TX timeout" debug messages

david decotigny (1):
  forcedeth: fix stats on hardware without extended stats support

 drivers/net/ethernet/nvidia/forcedeth.c |  342 ++++++++++++++++++++++---------
 1 files changed, 246 insertions(+), 96 deletions(-)

-- 
1.7.3.1
