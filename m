From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv2 0/2] net: fec: Reset ethernet PHY whenever the enet_out
 clock is being enabled
Date: Tue, 12 Jan 2016 16:17:54 +0100
Message-ID: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>, "David S. Miller" <davem@davemloft.net>,
 Fabio Estevam <fabio.estevam@freescale.com>,
 Greg Ungerer <gerg@uclinux.org>, Kevin Hao <haokexin@gmail.com>,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
 Lucas Stach <l.stach@pengutronix.de>, Nimrod Andy <B38611@freescale.com>,
 Philippe Reynes <tremyfr@gmail.com>,
 Richard Cochran <richardcochran@gmail.com>,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 Sascha Hauer <s.hauer@pengutronix.de>, Stefan Agner <stefan@agner.ch>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Kumar Gala <galak@codeaurora.org>, Mark Rutland <mark.rutland@arm.com>,
 Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>,
 Russell King <lin
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

This patchset fixes a regression introduced by
commit e8fcfcd5684a ("net: fec: optimize the clock management to save power")
for ethernet PHYs that are using ENET_OUT as reference clock (on i.MX6 or i.MX28)

Changes vs. v1:
- fixed reference to the commit that introduced the regression.
- dropped patch to use gpiod framework. This should be added later,
  after the affected DTBs have been updated to specify the correct
  gpio_flags.

Patch overview:
1. cleanup patch to remove redundant NULL checks
2. call fec_reset_phy() after the ENET_OUT clock has been enabled
