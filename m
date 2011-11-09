From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 0/9] forcedeth: stats & debug enhancements
Date: Wed,  9 Nov 2011 14:09:14 -0800
Message-ID: <cover.1320875577.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These changes implement the ndo_get_stats64 API and add a few more
stats and debugging features for forcedeth. They also ensure that
stats updates are correct in SMP systems, 32 or 64-bits.

Regarding the "implement ndo_get_stats64() API" patch, I'm not sure
I'm using the right way to protect the 64b stats. Ideally, I would
like them to be non-blocking (u64_stats_sync.h), but as there are
several sources for updates, I don't think I can do without locking or
per-CPU stats. Would per-CPU stats be better here (note: I expect the
contention on netdev_priv(dev)->stats_lock to be _VERY_ low)?

Tested:
  ~150Mbps incoming TCP, ethtool -S in a loop, x86_64 16-way:
     tx_bytes: 1413863329
     rx_packets: 38918872
     tx_packets: 19828148
     rx_bytes: 57818685991

############################################
# Patch Set Summary:

David Decotigny (6):
  forcedeth: expose module parameters in /sys/module
  forcedeth: stats for rx_packets based on hardware registers
  forcedeth: implement ndo_get_stats64() API
  forcedeth: account for dropped RX frames
  forcedeth: stats updated with a deferrable timer
  forcedeth: whitespace/indentation fixes

Mike Ditto (1):
  forcedeth: Add messages to indicate using MSI or MSI-X

Sameer Nanda (2):
  forcedeth: allow to silence "TX timeout" debug messages
  forcedeth: new ethtool stat counter for TX timeouts

 drivers/net/ethernet/nvidia/forcedeth.c |  271 +++++++++++++++++++++----------
 1 files changed, 184 insertions(+), 87 deletions(-)

-- 
1.7.3.1
