From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v5 0/5] forcedeth: minor fixes for stats, rmmod, sparse
Date: Sat,  5 Nov 2011 17:38:19 -0700
Message-ID: <cover.1320539724.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a minor update over v4, re-adding a patch I left aside to
study it.

Changes since v4:
 - added patch 1/5 fixing a rmmod race (see description for test
   details)
 - all other patches identical to v4

Changes since v3:
 - removed feature additions, this leaves minor sparse and stats
   fixes. Feature additions shipped previously will go to net-next

Changes since v2:
 - removed "Fix a race during rmmod of forcedeth" from the series
   (will look at it separately with original author)
 - added "remove unneeded stats updates" and "64-bit stats"
 - reordered patches

Changes since v1:
 - rebased on top of netdev tip
 - do not repeat name of device in netdev_dbg
 - do not completely mute TX timeout messages when debug_tx_timeout is
   not set
 - make debug_tx_timeout writable in /sys/module
 Note: I am re-submitting "expose module parameters in /sys/module" as
       it can be useful in production and I was assured it doesn't add
       much memory overhead by the sysfs maintainers.

Tested:
  16-way x86_64 SMP, dual forcedeth ->
  RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)


############################################
# Patch Set Summary:

David Decotigny (3):
  forcedeth: fix race when unloading module
  forcedeth: remove unneeded stats updates
  forcedeth: fix a few sparse warnings (variable shadowing)

Mandeep Baines (1):
  forcedeth: Improve stats counters

Mike Ditto (1):
  forcedeth: Acknowledge only interrupts that are being processed

 drivers/net/ethernet/nvidia/forcedeth.c |   88 +++++++++++--------------------
 1 files changed, 31 insertions(+), 57 deletions(-)

-- 
1.7.3.1
