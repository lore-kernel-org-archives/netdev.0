From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 0/6] net/macb: add HW features to macb driver
Date: Fri, 18 Jul 2014 16:21:12 +0200
Message-ID: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>, linux-kernel@vger.kernel.org
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
 <soren.brinkmann@xilinx.com>
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

Hi,

this series of patches adds new hardware features to macb driver. These
features can be enabled/disabled at runtime using ethtool. Depending on
hardware and design configuration, some are enabled by default whereas other
are disabled.

For instance, checksum offload features are enabled by default for gem designed
for packet buffer mode but disabled for fifo mode design or for old macb.

Besides, the scatter-gather feature is enabled and tested on macb but disabled
on sama5d3x gem. When testing this feature on sama5d3x gem, TX lockups occured
frequently.

These patches were made for net-next.git repository.

Cyrille Pitchen (5):
  net/macb: add scatter-gather hw feature
  net/macb: add TX checksum offload feature
  net/macb: add RX checksum offload feature
  ARM: at91: change compatibility string for sama5d3x gem
  net/macb: enable scatter-gather feature and set DMA burst length for
    sama5d4 gem

Nicolas Ferre (1):
  net/macb: configure for FIFO mode and non-gigabit

 arch/arm/boot/dts/sama5d3_gmac.dtsi |   2 +-
 drivers/net/ethernet/cadence/macb.c | 409 ++++++++++++++++++++++++++++++------
 drivers/net/ethernet/cadence/macb.h |  36 +++-
 3 files changed, 375 insertions(+), 72 deletions(-)

-- 
1.8.2.2
