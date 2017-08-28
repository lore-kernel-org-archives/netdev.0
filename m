From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net-next v3 0/3] NCSI VLAN Filtering Support
Date: Mon, 28 Aug 2017 16:18:40 +1000
Message-ID: <20170828061843.24349-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>, ratagupt@in.ibm.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series (mainly patch 2) adds VLAN filtering to the NCSI implementation.
A fair amount of code already exists in the NCSI stack for VLAN filtering but
none of it is actually hooked up. This goes the final mile and fixes a few
bugs in the existing code found along the way (patch 1).

Patch 3 adds the appropriate flag and callbacks to the ftgmac100 driver to
enable filtering as it's a large consumer of NCSI (and what I've been
testing on).

v3:	- Add comment describing change to ncsi_find_filter()
	- Catch NULL in clear_one_vid() from ncsi_get_filter()
	- Simplify state changes when kicking updated channel

Samuel Mendoza-Jonas (3):
  net/ncsi: Fix several packet definitions
  net/ncsi: Configure VLAN tag filter
  ftgmac100: Support NCSI VLAN filtering when available

 drivers/net/ethernet/faraday/ftgmac100.c |   5 +
 include/net/ncsi.h                       |   2 +
 net/ncsi/internal.h                      |  11 ++
 net/ncsi/ncsi-cmd.c                      |  10 +-
 net/ncsi/ncsi-manage.c                   | 308 ++++++++++++++++++++++++++++++-
 net/ncsi/ncsi-pkt.h                      |   2 +-
 net/ncsi/ncsi-rsp.c                      |  12 +-
 7 files changed, 339 insertions(+), 11 deletions(-)

-- 
2.14.0
