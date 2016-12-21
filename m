From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 00/27] net: mvpp2: add basic support for PPv2.2
Date: Wed, 21 Dec 2016 12:16:07 +0100
Message-ID: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
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

Hello,

The goal of this patch series is to add basic support for PPv2.2 in
the existing mvpp2 driver. mvpp2 currently supported the PPv2.1
version of the IP, used in the 32 bits Marvell Armada 375 SoC. PPv2.2
is an evolution of this IP block, used in the 64 bits Marvell Armada
7K/8K SoCs.

In order to ease the review, the introduction of PPv2.2 support has
been made into multiple small commits, with the final commit adding
the compatible string that makes the PPv2.2 support actually
usable. The series remain fully bisectable.

Here is a quick overview of the series:

 - Patch 1 updates the Device Tree binding documentation.

 - Patch 2 to 10 make improvements to the mvpp2 not directly related
   to the PPv2.2 support, but useful to have as they cleanup some dead
   code, fix a few issues, etc.

 - Patch 11 switches the driver to build_skb(), which is needed to
   support PPv2.2 (details in the commit log itself)

 - Patch 12 makes the driver build on 64 bits platform.

 - Patches 13 to 26 add the PPv2.2 support step by step.

 - Patch 27 finally adds the compatible string, which makes the PPv2.2
   support usable.

I'd like to thank Stefan Chulski and Marcin Wojtas, who helped me a
lot in the development of this patch series, by reviewing the patches,
and giving lots of useful hints to debug the driver on PPv2.2. Thanks!

Best regards,

Thomas


Thomas Petazzoni (27):
  dt-bindings: net: update Marvell PPv2 binding for PPv2.2 support
  net: mvpp2: handle too large value handling in
    mvpp2_rx_pkts_coal_set()
  net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
  net: mvpp2: release reference to txq_cpu[] entry after unmapping
  net: mvpp2: remove unused 'tx_skb' field of 'struct mvpp2_tx_queue'
  net: mvpp2: drop useless fields in mvpp2_bm_pool and related code
  net: mvpp2: simplify mvpp2_bm_bufs_add()
  net: mvpp2: remove unused register definitions
  net: mvpp2: fix indentation of MVPP2_EXT_GLOBAL_CTRL_DEFAULT
  net: mvpp2: simplify MVPP2_PRS_RI_* definitions
  net: mvpp2: switch to build_skb() in the RX path
  net: mvpp2: enable building on 64-bit platforms
  net: mvpp2: add and use accessors for TX/RX descriptors
  net: mvpp2: add ip_version field in "struct mvpp2"
  net: mvpp2: introduce an intermediate union for the TX/RX descriptors
  net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors
  net: mvpp2: adjust the allocation/free of BM pools for PPv2.2
  net: mvpp2: adapt the mvpp2_rxq_*_pool_set functions to PPv2.2
  net: mvpp2: adapt mvpp2_defaults_set() to PPv2.2
  net: mvpp2: adjust mvpp2_{rxq,txq}_init for PPv2.2
  net: mvpp2: handle register mapping and access for PPv2.2
  net: mvpp2: handle misc PPv2.1/PPv2.2 differences
  net: mvpp2: add AXI bridge initialization for PPv2.2
  net: mvpp2: rework RXQ interrupt group initialization for PPv2.2
  net: mvpp2: adapt rxq distribution to PPv2.2
  net: mvpp2: add support for an additional clock needed for PPv2.2
  net: mvpp2: finally add the PPv2.2 compatible string

 .../devicetree/bindings/net/marvell-pp2.txt        |  66 +-
 drivers/net/ethernet/marvell/Kconfig               |   2 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 940 ++++++++++++++++-----
 3 files changed, 789 insertions(+), 219 deletions(-)

-- 
2.7.4
