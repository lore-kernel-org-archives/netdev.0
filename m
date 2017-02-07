From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 00/12] net: dsa: remove unnecessary phy.h include
Date: Tue,  7 Feb 2017 15:02:53 -0800
Message-ID: <20170207230305.18222-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
        Nick Kossifidis <mickflemm@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Ralf Baechle <ralf@l
To: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        target-devel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi all,

Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
unnecessary dependency for quite a large amount of the kernel.  There's
very little which actually requires definitions from phy.h in net/dsa.h
- the include itself only wants the declaration of a couple of
structures and IFNAMSIZ.

Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
and phy_fixed.h from net/dsa.h.

This patch reduces from around 800 files rebuilt to around 40 - even
with ccache, the time difference is noticable.

In order to make this change, several drivers need to be updated to
include necessary headers that they were picking up through this
include.  This has resulted in a much larger patch series.

I'm assuming the 0-day builder has had 24 hours with this series, and
hasn't reported any further issues with it - the last issue was two
weeks ago (before I became ill) which I fixed over the last weekend.

I'm hoping this doesn't conflict with what's already in net-next...

David, this should probably go via your tree considering the diffstat.

Changes in v2:

- took Russell's patch series
- removed Qualcomm EMAC patch
- rebased against net-next/master

Russell King (12):
  net: sunrpc: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: cgroups: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: macb: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: lan78xx: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: bgmac: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: fman: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: mvneta: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  iscsi: fix build errors when linux/phy*.h is removed from net/dsa.h
  MIPS: Octeon: Remove unnecessary MODULE_*()
  net: liquidio: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: ath5k: fix build errors when linux/phy*.h is removed from
    net/dsa.h
  net: dsa: remove unnecessary phy*.h includes

 arch/mips/cavium-octeon/octeon-platform.c             | 4 ----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h                 | 1 +
 drivers/net/ethernet/broadcom/bgmac.c                 | 2 ++
 drivers/net/ethernet/cadence/macb.h                   | 2 ++
 drivers/net/ethernet/cavium/liquidio/lio_main.c       | 1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c    | 1 +
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 1 +
 drivers/net/ethernet/freescale/fman/fman_memac.c      | 1 +
 drivers/net/ethernet/marvell/mvneta.c                 | 1 +
 drivers/net/usb/lan78xx.c                             | 1 +
 drivers/net/wireless/ath/ath5k/ahb.c                  | 2 +-
 drivers/target/iscsi/iscsi_target_login.c             | 1 +
 include/net/dsa.h                                     | 5 +++--
 net/core/netprio_cgroup.c                             | 1 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c            | 1 +
 15 files changed, 18 insertions(+), 7 deletions(-)

-- 
2.9.3
