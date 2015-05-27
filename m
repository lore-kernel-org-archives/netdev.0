From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net-next v6 0/2] Adding support for Cavium ThunderX network
 controller
Date: Tue, 26 May 2015 19:20:13 -0700
Message-ID: <1432693228-5554-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <robert.richter@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 David Daney <david.daney@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patchset adds support for the Cavium ThunderX network controller.

changes in v6:
 * unused preprocessor symbols were removed
 * reduce no of atomic operations in SQ maintenance
 * support for TCP segmentation at driver level
 * reset RBDR if fifo state is FAIL
 * fixed an issue with link state mailbox message

changes in v5:
 * __packed were removed.  now we rely on C language ABI
 * nic_dbg() -> netdev_dbg()
 * fixes for a typo, constant spelling and using BIT_ULL
 * use print_hex_dump()
 * unnecessary conditions in a long if() chain were removed

changes in v4:
 * the patch "pci: Add Cavium PCI vendor id" was attributed correctly
 * a note that Cavium id is used in many drivers was added
 * the license comments now match MODULE_LICENSE
 * a comment explaining usage of writeq_relaxed()/readq_relaxed() was added

changes in v3:
 * code cleanup
 * issues discovered by reviewers were addressed

changes in v2:
 * non-generic module parameters removed
 * ethtool support added (nicvf_set_rxnfc())

v5: https://lkml.kernel.org/g/<1432344498-17131-1-git-send-email-aleksey.makarov@caviumnetworks.com>
v4: https://lkml.kernel.org/g/<1432000757-28700-1-git-send-email-aleksey.makarov@auriga.com>
v3: https://lkml.kernel.org/g/<1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
v2: https://lkml.kernel.org/g/<1415596445-10061-1-git-send-email-rric@kernel.org>
v1: https://lkml.kernel.org/g/<20141030165434.GW20170@rric.localhost>

Sunil Goutham (2):
  pci: Add Cavium PCI vendor id
  net: Adding support for Cavium ThunderX network controller

 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cavium/Kconfig                |   40 +
 drivers/net/ethernet/cavium/Makefile               |    5 +
 drivers/net/ethernet/cavium/thunder/Makefile       |   11 +
 drivers/net/ethernet/cavium/thunder/nic.h          |  414 ++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  940 ++++++++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  213 +++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  601 ++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 1332 +++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 1544 ++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  381 +++++
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  701 +++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  966 ++++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |  223 +++
 include/linux/pci_ids.h                            |    2 +
 17 files changed, 7382 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/Kconfig
 create mode 100644 drivers/net/ethernet/cavium/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_reg.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/q_struct.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.h

-- 
2.4.1
