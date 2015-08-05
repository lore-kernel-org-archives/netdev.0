From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Wed, 5 Aug 2015 17:42:23 +0300
Message-ID: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<Igal.Liberman@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <grant.likely@linaro.org>,
	<robh+dt@kernel.org>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FMan MAC configuration code needs the speed and duplex information
for fixed-link interfaces that is parsed now by the of function
of_phy_register_fixed_link(). This parses the fixed-link parameters but
does not expose to the caller neither the phy_device pointer nor the
status struct where it loads the fixed-link params. By extracting the
fixed-link parsing code from of_phy_register_fixed_link() into a
separate function the parsed values are made available without changing
the existing API. This change also removes a small redundancy in the
previous code calling fixed_phy_register().

The FMan patch relies on the latest FMan driver v4 submission by Igal Liberman:
https://patchwork.ozlabs.org/project/netdev/list/?submitter=Igal.Liberman&state=*&q=v4

Madalin Bucur (2):
  of: separate fixed link parsing from registration
  fsl_fman: use fixed_phy_status for MEMAC

 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  6 ++-
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  2 +-
 drivers/net/ethernet/freescale/fman/mac/fm_memac.c | 42 ++++++++++++-----
 drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  3 +-
 drivers/net/ethernet/freescale/fman/mac/mac.c      | 18 ++++++--
 drivers/of/of_mdio.c                               | 52 ++++++++++++++--------
 include/linux/of_mdio.h                            |  9 ++++
 7 files changed, 94 insertions(+), 38 deletions(-)

-- 
1.7.11.7
