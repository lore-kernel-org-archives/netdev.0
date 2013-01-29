From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/5] mv643xx_eth: use mvmdio MDIO bus driver
Date: Tue, 29 Jan 2013 16:24:03 +0100
Message-ID: <1359473048-26551-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Russell King <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 Rob Herring <rob.herring@calxeda.com>,
 Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
 Paul Mackerras <paulus@samba.org>, linux-arm-kernel@lists.infradead.org,
 Rob Landley <rob@landley.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linuxppc-dev@lists.ozlabs.org, Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch converts the mv643xx_eth driver to use the mvmdio MDIO bus driver
instead of rolling its own implementation. As a result, all users of this
mv643xx_eth driver are converted to register an "orion-mdio" platform_device.
The mvmdio driver is also updated to support an interrupt line which reports
SMI error/completion, and to allow traditionnal platform device registration
instead of just device tree.

David, I think it makes sense for you to merge all of this, since we do
not want the architecture files to be desynchronized from the mv643xx_eth to
avoid runtime breakage. The potential for merge conflicts should be very small.

You can probably safely merge patches 1 to 4 if Thomas agrees, and we will
see what kind of feeback I get on patch 5.

Florian Fainelli (5):
  net: mvmdio: unmap base register address at driver removal
  net: mvmdio: rename base register cookie from smireg to regs
  net: mvmdio: enhance driver to support SMI error/done interrupts
  net: mvmdio: allow Device Tree and platform device to coexist
  mv643xx_eth: convert to use the Marvell Orion MDIO driver

 .../devicetree/bindings/net/marvell-orion-mdio.txt |    3 +
 arch/arm/plat-orion/common.c                       |   84 +++++++--
 arch/powerpc/platforms/chrp/pegasos_eth.c          |   20 +++
 arch/powerpc/sysdev/mv64x60_dev.c                  |   14 +-
 drivers/net/ethernet/marvell/Kconfig               |    1 +
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  187 +-------------------
 drivers/net/ethernet/marvell/mvmdio.c              |  136 +++++++++++---
 7 files changed, 226 insertions(+), 219 deletions(-)

-- 
1.7.10.4
