From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Subject: RE: [PATCH 1/8] netdev: separate out davinci mdio controller code
Date: Tue, 3 Aug 2010 18:29:46 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043F3C8C2A@dlee03.ent.ti.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com>
 <1280842313-3743-2-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Nori, Sekhar" <nsekhar@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"Chemparathy, Cyril" <cyril@ti.com>
To: "Chemparathy, Cyril" <cyril@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.c
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:49973 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756711Ab0HCX3q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:29:46 -0400
In-Reply-To: <1280842313-3743-2-git-send-email-cyril@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>From: linux-omap-owner@vger.kernel.org [mailto:linux-omap-owner@vger.kernel.org] On Behalf Of Cyril
>Chemparathy
>
>Davinci's MDIO controller is present on other TI devices, without an
>accompanying EMAC.  For example, on tnetv107x, the same MDIO module is used in
>conjunction with a 3-port switch hardware.
>
>By separating the MDIO controller code into its own platform driver, this
>patch allows common logic to be reused on such platforms.
>
>Signed-off-by: Cyril Chemparathy <cyril@ti.com>
>---
> drivers/net/Kconfig          |   10 +
> drivers/net/Makefile         |    1 +
> drivers/net/davinci_mdio.c   |  386 ++++++++++++++++++++++++++++++++++++++++++
> include/linux/davinci_emac.h |    4 +
> 4 files changed, 401 insertions(+), 0 deletions(-)
> create mode 100644 drivers/net/davinci_mdio.c
>
[...]
>diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
>new file mode 100644
>index 0000000..d34a53a
>--- /dev/null
>+++ b/drivers/net/davinci_mdio.c
[...]
>+
>+/* wait until hardware is ready for another user access */
>+static inline u32 wait_for_user_access(struct davinci_mdio_data *data)
>+{
>+	struct davinci_mdio_regs __iomem *regs = data->regs;
>+	u32 reg;
>+
>+	while ((reg = __raw_readl(&regs->user[0].access)) & USERACCESS_GO)
>+		;

potential infinite loop? I saw another place in your series using time_after, might fit in here too.

>+
>+	return reg;
>+}
>+
>+/* wait until hardware state machine is idle */
>+static inline void wait_for_idle(struct davinci_mdio_data *data)
>+{
>+	struct davinci_mdio_regs __iomem *regs = data->regs;
>+
>+	while ((__raw_readl(&regs->control) & CONTROL_IDLE) == 0)
>+		;

Ditto

>+}
>+
[...]

Regards,

omar
