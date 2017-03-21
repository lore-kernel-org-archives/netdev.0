From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [v5,net-next,2/9] net: stmmac: configure mtl rx and tx algorithms
Date: Tue, 21 Mar 2017 15:33:57 +0100
Message-ID: <20170321143357.GH30407@ulmo.ba.sec>
References: <aa027812f1ab084c3d1e578369cd35c3be3b7f96.1489169213.git.jpinto@synopsys.com>
 <20170321115804.GA5377@ulmo.ba.sec>
 <1020202a-5b96-0c11-a5de-fbd93ff02323@synopsys.com>
 <20170321122426.GE30407@ulmo.ba.sec>
 <b869becd-899b-1366-cdca-a32820fb8610@synopsys.com>
 <20170321140816.GF30407@ulmo.ba.sec>
 <a878b9ce-0eaa-ab10-c3d8-d98020f64bd5@synopsys.com>
 <20170321142302.GC4589@Red>
 <484e880c-89f1-dd61-52df-4d9474422f05@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ISKrrfpKsPiF35CV"
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>, davem@davemloft.net,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33261 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933085AbdCUOeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 10:34:06 -0400
Received: by mail-wm0-f66.google.com with SMTP id n11so3269955wma.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 07:34:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <484e880c-89f1-dd61-52df-4d9474422f05@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ISKrrfpKsPiF35CV
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 02:25:15PM +0000, Joao Pinto wrote:
> =C3=80s 2:23 PM de 3/21/2017, Corentin Labbe escreveu:
> > On Tue, Mar 21, 2017 at 02:10:47PM +0000, Joao Pinto wrote:
> >> ++Adding Corentin
> >>
> >> =C3=80s 2:08 PM de 3/21/2017, Thierry Reding escreveu:
> >>> On Tue, Mar 21, 2017 at 01:58:36PM +0000, Joao Pinto wrote:
> >>>> =C3=80s 12:24 PM de 3/21/2017, Thierry Reding escreveu:
> >>>>> On Tue, Mar 21, 2017 at 12:02:03PM +0000, Joao Pinto wrote:
> >>>>>> =C3=80s 11:58 AM de 3/21/2017, Thierry Reding escreveu:
> >>>>>>> On Fri, Mar 10, 2017 at 06:24:52PM +0000, Joao Pinto wrote:
> >>>>>>>> This patch adds the RX and TX scheduling algorithms programming.
> >>>>>>>> It introduces the multiple queues configuration function
> >>>>>>>> (stmmac_mtl_configuration) in stmmac_main.
> >>>>>>>>
> >>>>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> >>>>>>>> ---
> >>>>>>>> Changes v4->v5:
> >>>>>>>> - patch title update (stmicro replaced by stmmac)
> >>>>>>>> Changes v3->v4:
> >>>>>>>> - Just to keep up with patch-set version
> >>>>>>>> Changes v2->v3:
> >>>>>>>> - Switch statements with a tab
> >>>>>>>> Changes v1->v2:
> >>>>>>>> - Just to keep up with patch-set version
> >>>>>>>>
> >>>>>>>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++
> >>>>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 10 +++++
> >>>>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 48 ++++++++=
+++++++++++++++
> >>>>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 31 ++++++++=
+++++--
> >>>>>>>>  4 files changed, 90 insertions(+), 3 deletions(-)
> >>>>>>>
> >>>>>>> This patch breaks backwards-compatibility with DTBs that don't ha=
ve an
> >>>>>>> of the multiple queue properties.
> >>>>>>>
> >>>>>>> See below...
> >>>>>>>
> >>>>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/driv=
ers/net/ethernet/stmicro/stmmac/common.h
> >>>>>>>> index 04d9245..5a0a781 100644
> >>>>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> >>>>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> >>>>>>>> @@ -455,6 +455,10 @@ struct stmmac_ops {
> >>>>>>>>  	int (*rx_ipc)(struct mac_device_info *hw);
> >>>>>>>>  	/* Enable RX Queues */
> >>>>>>>>  	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
> >>>>>>>> +	/* Program RX Algorithms */
> >>>>>>>> +	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32=
 rx_alg);
> >>>>>>>> +	/* Program TX Algorithms */
> >>>>>>>> +	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32=
 tx_alg);
> >>>>>>>>  	/* Dump MAC registers */
> >>>>>>>>  	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
> >>>>>>>>  	/* Handle extra events on specific interrupts hw dependent */
> >>>>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/driv=
ers/net/ethernet/stmicro/stmmac/dwmac4.h
> >>>>>>>> index db45134..748ab6f 100644
> >>>>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> >>>>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> >>>>>>>> @@ -161,6 +161,16 @@ enum power_event {
> >>>>>>>>  #define GMAC_HI_REG_AE			BIT(31)
> >>>>>>>> =20
> >>>>>>>>  /*  MTL registers */
> >>>>>>>> +#define MTL_OPERATION_MODE		0x00000c00
> >>>>>>>> +#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
> >>>>>>>> +#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
> >>>>>>>> +#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
> >>>>>>>> +#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
> >>>>>>>> +#define MTL_OPERATION_SCHALG_SP		(0x3 << 5)
> >>>>>>>> +#define MTL_OPERATION_RAA		BIT(2)
> >>>>>>>> +#define MTL_OPERATION_RAA_SP		(0x0 << 2)
> >>>>>>>> +#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
> >>>>>>>> +
> >>>>>>>>  #define MTL_INT_STATUS			0x00000c20
> >>>>>>>>  #define MTL_INT_Q0			BIT(0)
> >>>>>>>> =20
> >>>>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b=
/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >>>>>>>> index 1e79e65..f966755 100644
> >>>>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >>>>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >>>>>>>> @@ -70,6 +70,52 @@ static void dwmac4_rx_queue_enable(struct mac=
_device_info *hw, u32 queue)
> >>>>>>>>  	writel(value, ioaddr + GMAC_RXQ_CTRL0);
> >>>>>>>>  }
> >>>>>>>> =20
> >>>>>>>> +static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_inf=
o *hw,
> >>>>>>>> +					  u32 rx_alg)
> >>>>>>>> +{
> >>>>>>>> +	void __iomem *ioaddr =3D hw->pcsr;
> >>>>>>>> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> >>>>>>>> +
> >>>>>>>> +	value &=3D ~MTL_OPERATION_RAA;
> >>>>>>>> +	switch (rx_alg) {
> >>>>>>>> +	case MTL_RX_ALGORITHM_SP:
> >>>>>>>> +		value |=3D MTL_OPERATION_RAA_SP;
> >>>>>>>> +		break;
> >>>>>>>> +	case MTL_RX_ALGORITHM_WSP:
> >>>>>>>> +		value |=3D MTL_OPERATION_RAA_WSP;
> >>>>>>>> +		break;
> >>>>>>>> +	default:
> >>>>>>>> +		break;
> >>>>>>>> +	}
> >>>>>>>> +
> >>>>>>>> +	writel(value, ioaddr + MTL_OPERATION_MODE);
> >>>>>>>> +}
> >>>>>>>> +
> >>>>>>>> +static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_inf=
o *hw,
> >>>>>>>> +					  u32 tx_alg)
> >>>>>>>> +{
> >>>>>>>> +	void __iomem *ioaddr =3D hw->pcsr;
> >>>>>>>> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> >>>>>>>> +
> >>>>>>>> +	value &=3D ~MTL_OPERATION_SCHALG_MASK;
> >>>>>>>> +	switch (tx_alg) {
> >>>>>>>> +	case MTL_TX_ALGORITHM_WRR:
> >>>>>>>> +		value |=3D MTL_OPERATION_SCHALG_WRR;
> >>>>>>>> +		break;
> >>>>>>>> +	case MTL_TX_ALGORITHM_WFQ:
> >>>>>>>> +		value |=3D MTL_OPERATION_SCHALG_WFQ;
> >>>>>>>> +		break;
> >>>>>>>> +	case MTL_TX_ALGORITHM_DWRR:
> >>>>>>>> +		value |=3D MTL_OPERATION_SCHALG_DWRR;
> >>>>>>>> +		break;
> >>>>>>>> +	case MTL_TX_ALGORITHM_SP:
> >>>>>>>> +		value |=3D MTL_OPERATION_SCHALG_SP;
> >>>>>>>> +		break;
> >>>>>>>> +	default:
> >>>>>>>> +		break;
> >>>>>>>> +	}
> >>>>>>>> +}
> >>>>>>>> +
> >>>>>>>>  static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *r=
eg_space)
> >>>>>>>>  {
> >>>>>>>>  	void __iomem *ioaddr =3D hw->pcsr;
> >>>>>>>> @@ -457,6 +503,8 @@ static const struct stmmac_ops dwmac4_ops =
=3D {
> >>>>>>>>  	.core_init =3D dwmac4_core_init,
> >>>>>>>>  	.rx_ipc =3D dwmac4_rx_ipc_enable,
> >>>>>>>>  	.rx_queue_enable =3D dwmac4_rx_queue_enable,
> >>>>>>>> +	.prog_mtl_rx_algorithms =3D dwmac4_prog_mtl_rx_algorithms,
> >>>>>>>> +	.prog_mtl_tx_algorithms =3D dwmac4_prog_mtl_tx_algorithms,
> >>>>>>>>  	.dump_regs =3D dwmac4_dump_regs,
> >>>>>>>>  	.host_irq_status =3D dwmac4_irq_status,
> >>>>>>>>  	.flow_ctrl =3D dwmac4_flow_ctrl,
> >>>>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b=
/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>>>> index 4498a38..af57f8d 100644
> >>>>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>>>> @@ -1645,6 +1645,31 @@ static void stmmac_init_tx_coalesce(struc=
t stmmac_priv *priv)
> >>>>>>>>  }
> >>>>>>>> =20
> >>>>>>>>  /**
> >>>>>>>> + *  stmmac_mtl_configuration - Configure MTL
> >>>>>>>> + *  @priv: driver private structure
> >>>>>>>> + *  Description: It is used for configurring MTL
> >>>>>>>> + */
> >>>>>>>> +static void stmmac_mtl_configuration(struct stmmac_priv *priv)
> >>>>>>>> +{
> >>>>>>>> +	u32 rx_queues_count =3D priv->plat->rx_queues_to_use;
> >>>>>>>> +	u32 tx_queues_count =3D priv->plat->tx_queues_to_use;
> >>>>>>>> +
> >>>>>>>> +	/* Configure MTL RX algorithms */
> >>>>>>>> +	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorith=
ms)
> >>>>>>>> +		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
> >>>>>>>> +						priv->plat->rx_sched_algorithm);
> >>>>>>>> +
> >>>>>>>> +	/* Configure MTL TX algorithms */
> >>>>>>>> +	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorith=
ms)
> >>>>>>>> +		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
> >>>>>>>> +						priv->plat->tx_sched_algorithm);
> >>>>>>>> +
> >>>>>>>> +	/* Enable MAC RX Queues */
> >>>>>>>> +	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> >>>>>>>> +		stmmac_mac_enable_rx_queues(priv);
> >>>>>>>
> >>>>>>> This is almost equivalent to the code removed from stmmac_hw_setu=
p()
> >>>>>>> which happens to be the key for this driver to work for me. Howev=
er, the
> >>>>>>> code above adds an additional check for rx_queues_count > 1 which=
 is
> >>>>>>> going to be false for any existing DTB, because it is derived fro=
m the
> >>>>>>> values retrieved from new device tree properties.
> >>>>>>>
> >>>>>>> So I think for backwards compatibility we'd need something like t=
his:
> >>>>>>>
> >>>>>>> 	if ((rx_queue_count =3D=3D 0 || rx_queue_count > 1) &&
> >>>>>>> 	    priv->hw->mac->rx_queue_enable)
> >>>>>>>
> >>>>>>> But then I'm beginning to think maybe we don't need a check here =
at all
> >>>>>>> because it would only prevent RX queue setup for rx_queue_count =
=3D=3D 1 and
> >>>>>>> I think it would still be legitimate to set it up even then.
> >>>>>>>
> >>>>>>> stmmac_mac_enable_rx_queues() already checks for rx_count =3D=3D =
1, but that
> >>>>>>> is derived from the number of RX queues derived from the feature
> >>>>>>> registers and therefore refers to the number of queues that the h=
ardware
> >>>>>>> supports as opposed to the number of queues configured in device =
tree.
> >>>>>>>
> >>>>>>> I can follow up with a patch to restore backwards-compatibility.
> >>>>>>
> >>>>>> Forhw configured as single queue you don't need to enable the rx q=
ueue, since
> >>>>>> they are enable by default. if you check in stmmac_platform.c I as=
sure backward
> >>>>>> compatibility by setting the number of rx and tx queues =3D 1 if n=
othing is
> >>>>>> declared. Please check here:
> >>>>>>
> >>>>>> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__git.kernel.=
org_pub_scm_linux_kernel_git_davem_net-2Dnext.git_tree_drivers_net_ethernet=
_stmicro_stmmac_stmmac-5Fplatform.c-23n156&d=3DDwIFaQ&c=3DDPL6_X_6JkXFx7AXW=
qB0tg&r=3Ds2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=3DtvYpf8cZr-Y6Zl-d7=
NlT2FEW7Gv5Bzs86GMIhZs4OSI&s=3DjA0P7-MXCVOtu262fF75EhUq5dfcDutzsYg8CAE6XQc&=
e=3D=20
> >>>>>
> >>>>> Ah yes, I just ran across that trying to debug why a subsequent pat=
ch
> >>>>> broke things again. I think the rx_queue_count > 1 condition is sti=
ll
> >>>>> wrong in the above because it will still fail for the backwards-
> >>>>> compatibility case.
> >>>>
> >>>> Enabling RX Queue is needed only if the hw is configured as having m=
ore than 1
> >>>> RX queue. If your hardware is configured as being multiple-queue,
> >>>> rx_queue_to_use should be > 1. True single queue hardware will work =
fine.
> >>>
> >>> But that's certainly not the case right now. The rx_queues_to_use fie=
ld
> >>> is initialized based on the new snps,rx-queues-to-use device tree
> >>> property, or initialized to 1 in the absence of that property (and for
> >>> PCI). Effectively that means all users of this driver will have their
> >>> rx_queues_to_use field set to 1 until the DTS files are updated to set
> >>> some other value. But that's not a requirement that we can impose. We
> >>> still need to be able to deal with old device trees without regressio=
n.
> >>>
> >>> Even without the backwards-compatibility argument, wouldn't it make
> >>> sense to allow users to restrict usage to a single RX queue even on
> >>> hardware that supports multiple ones? It certainly works fine in my
> >>> case, I don't see any advantage in forbidding it.
> >>
> >> Corentin spotted the real problem! By mistake I restricted dma_op_mode
> >> configuration to IP Cores Version >=3D 4.00. Thank you Corentin for sp=
otting that
> >> one! Do you want to make the fix or do you want me to do it and put the
> >> reported-by tag?
> >=20
> > reported-by would be enougth.
> >=20
> > But I found also that rx_queues_to_use/tx_queues_to_use are not 1 by de=
fault.
> >=20
> > The following code exit stmmac_mtl_setup() before rx_queues_to_use/tx_q=
ueues_to_use are set.
> > rx_node =3D of_parse_phandle(pdev->dev.of_node, "snps,mtl-rx-config", 0=
);
> >=20
> > The default value must be set elsewhere.
> >=20
>=20
> Yes you are right, I just have a pci setup, so I was not able to test it =
sorry.
> I will fix that and add you to the thread. Thanks for checking that!

I've got a set of patches that fix all these issues and that I've tested
on Tegra186. Will send out soon.

Thierry

--ISKrrfpKsPiF35CV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljROdIACgkQ3SOs138+
s6GrCBAAwMaXv0C3ufLJ4+4NuAUZKnMqoK200NVpjOKlNYl3GSgJOLzbwGRpveDX
/kg0Z2PZ+f1GtwawDemt8n27ucVIcNhscueOXnpvX0+mODSW8Yy4RqqkYhanl4GA
kBWz5Gn19qyKzM/sfOFASCMwZ4afY7ujXwZf3KgQ4gc1+NObY6/ZfWfXGLCahJXe
R9dvGWNr66salfeidGiKSMyQFzj0PJoccdit5VSfneVW5MqE5mfiXzXFscVg3cRi
joClPO/fAIR5HXbmefZ4Q79154gvsDQqGVNJcdunC7SDGwCQZVTWAngltTzkLp3I
w8W5IYB8GzWleNildHVZkRCstQ8nBS06nUh4FRlfcHTAtyDZhl3GI2N5dHtaZigZ
rNwEU3lKbjahqI999/gOC9cEOLMtfunm387o8cgKqYFQ8E9qGs9gcsx81eze6EA8
K5JH6LDn3G4Zw1v/CRkzRHu/MFhVUBJd8w/rZ5UX27bBzuJq1E2x4k+G+TtOMlZV
yXAtfUsBVmG+i2DxuheFxMmSu6nPYwbpR72o7kgMy/unAzJ620/uj/IWmgqZm/2i
f81XOUp3hUuDXweMqthl17goIys8Ninauz+95ArM5mpk4V63A2bgTUV7jnB068xO
qs4ofvof+Ty7rwdRaK47DRUeScxlLU0s8WILTwimwhTL5HaAxAc=
=IfHC
-----END PGP SIGNATURE-----

--ISKrrfpKsPiF35CV--
