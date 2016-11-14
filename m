From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net.git) 0/3] stmmac: fix PTP support
Date: Mon, 14 Nov 2016 09:27:27 +0100
Message-ID: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>, <rayagond@vayavyalabs.com>,
        <richardcochran@gmail.com>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <seraphin.bonnaffe@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This subset of patches aim to fix the PTP support
for the stmmac and especially for 4.x chip series.
While setting PTP on an ST box with 4.00a Ethernet
core, the kernel panics due to a broken settings
of the descriptors. The patches review the
register configuration, the algo used for configuring
the protocol, the way to get the timestamp inside
the RX/TX descriptors and, in the end, the statistics
displayed by ethtool.

V2: RESEND all the patches adding the Acked-by.

Giuseppe Cavallaro (3):
  stmmac: update the PTP header file
  stmmac: fix PTP support for GMAC4
  stmmac: fix PTP type ethtool stats

 drivers/net/ethernet/stmicro/stmmac/common.h       | 24 +++---
 drivers/net/ethernet/stmicro/stmmac/descs.h        | 20 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 95 ++++++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h |  4 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 28 ++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 19 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  | 43 ++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 97 +++++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   | 72 ++++++++--------
 11 files changed, 260 insertions(+), 152 deletions(-)

-- 
2.7.4
