From: Christian Ruppert <christian.ruppert@abilis.com>
Subject: Re: [PATCH] Prevent interrupt loop with DWMAC MMC RX IPC Counter
Date: Fri, 15 Feb 2013 15:48:17 +0100
Message-ID: <20130215144815.GA31098@ab42.lan>
References: <1360934123-30476-1-git-send-email-christian.ruppert@abilis.com>
 <511E3C28.7090101@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <511E3C28.7090101@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Guiseppe,

Thanks for the feedback. I'll send a new patch shortly which
unconditionally masks the interrupts as you suggest. The mask register
does not exist in DWMACs without RX IPC counters, however, and I have n=
o
way of testing if accessing this register nevertheless generates a bus
error. Do you have hardware to verify if everything works fine even
without RX IPC counters before integrating the patch?

Greetings,
  Christian

On Fri, Feb 15, 2013 at 02:46:16PM +0100, Giuseppe CAVALLARO wrote:
> Hello Christian
>=20
> On 2/15/2013 2:15 PM, Christian Ruppert wrote:
> >If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unm=
anaged
> >and unacknowledged interrupt is generated after some time of operati=
on. To
> >my knowledge there is no way to autodetect this configuration.
> >
> >This patch adds a Kconfig option to tell the driver about the counte=
r which
> >in turn masks the undesired interrupts.
> >
> >Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>
> >---
> >  drivers/net/ethernet/stmicro/stmmac/Kconfig    |    8 ++++++++
> >  drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    3 +++
> >  2 files changed, 11 insertions(+), 0 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/n=
et/ethernet/stmicro/stmmac/Kconfig
> >index 1164930..60e5130 100644
> >--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> >+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> >@@ -71,5 +71,13 @@ config STMMAC_CHAINED
> >
> >  endchoice
> >
> >+config STMMAC_RX_IPC_CTRS
> >+	bool "MMC Receive IPC Counters enabled"
> >+	depends on STMMAC_ETH
> >+	default n
> >+	---help---
> >+	  Select this option in case MMC Receive IPC counters were enabled=
 at
> >+	  synthesis time of the block. If this option is not set correctly=
,
> >+	  system might hang after a certain amount of time.
> >
> >  endif
> >diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/driver=
s/net/ethernet/stmicro/stmmac/mmc_core.c
> >index 0c74a70..ae877ee 100644
> >--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
> >+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
> >@@ -149,6 +149,9 @@ void dwmac_mmc_intr_all_mask(void __iomem *ioadd=
r)
> >  {
> >  	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
> >  	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
> >+#ifdef CONFIG_STMMAC_RX_IPC_CTRS
> >+	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_IPC_INTR_MASK);
> >+#endif
>=20
> your fix makes sense to me; I have never faced this problem because t=
he
> MMC RX IPC Counter is not synthesised  on the GMAC chip I used.
>=20
> Anyway all mmc interrupts are not managed by defsign so I only ask
> you to remove the Kconfig option and add the writel in the
> dwmac_mmc_intr_all_mask.
>=20
> peppe
>=20
> >  }
> >
> >  /* This reads the MAC core counters (if actaully supported).
> >
>=20

--=20
  Christian Ruppert              ,          <christian.ruppert@abilis.c=
om>
                                /|
  Tel: +41/(0)22 816 19-42     //|                 3, Chemin du Pr=E9-F=
leuri
                             _// | bilis Systems   CH-1228 Plan-les-Oua=
tes
