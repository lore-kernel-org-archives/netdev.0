From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 00/11] use of_property_read_bool
Date: Fri,  5 Aug 2016 10:56:40 +0200
Message-ID: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, kernel-janitors@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-mmc@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-gpio@vger.kernel.org,
 linux-i2c@vger.kernel.org, linux-serial@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <alsa-devel-bounces@alsa-project.org>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Use of_property_read_bool to check for the existence of a property.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e1,e2;
statement S2,S1;
@@
-       if (of_get_property(e1,e2,NULL))
+       if (of_property_read_bool(e1,e2))
        S1 else S2
// </smpl>

---

 arch/powerpc/sysdev/mpic.c                  |    2 +-
 drivers/i2c/busses/i2c-mpc.c                |    2 +-
 drivers/mmc/host/sdhci-of-esdhc.c           |    2 +-
 drivers/net/ethernet/freescale/xgmac_mdio.c |    3 +--
 drivers/phy/phy-qcom-ufs.c                  |    2 +-
 drivers/pinctrl/nomadik/pinctrl-nomadik.c   |    2 +-
 drivers/soc/fsl/qe/qe_tdm.c                 |    2 +-
 drivers/soc/ti/knav_qmss_queue.c            |    2 +-
 drivers/tty/serial/atmel_serial.c           |    8 ++++----
 drivers/usb/host/fsl-mph-dr-of.c            |    6 +++---
 sound/soc/codecs/ab8500-codec.c             |   10 +++++-----
 sound/soc/sh/rcar/ssi.c                     |    2 +-
 sound/soc/soc-core.c                        |    2 +-
 13 files changed, 22 insertions(+), 23 deletions(-)
