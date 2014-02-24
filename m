From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 0/2] ixgbe, fix numa issues
Date: Mon, 24 Feb 2014 13:51:51 -0500
Message-ID: <1393267913-28212-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>, nhorman@redhat.com,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	agospoda@redhat.com, John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The ixgbe driver makes some assumptions about the layout of cpus in the
system which are not always correct given a particular system layout.  The
ixgbe driver allocates one MSI/cpu for queue usage but the code does not take
into account that devices are located on NUMA nodes and that the cpus in a node
are not contiguous.

These issues were found while doing cpu hotplug testing, however, both of these
issues can lead to obvious system performance issues as they defeat the
purpose of having one MSI processing a queue per cpu.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: nhorman@redhat.com
Cc: agospoda@redhat.com
Cc: e1000-devel@lists.sourceforge.net

Prarit Bhargava (2):
  ixgbe, make interrupt allocations NUMA aware
  ixgbe, don't assume mapping of numa node cpus

 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |   44 ++++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 +--
 4 files changed, 42 insertions(+), 15 deletions(-)

-- 
1.7.9.3


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
