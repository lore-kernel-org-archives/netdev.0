From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [PATCH RFC 02/11] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 18 Mar 2015 18:02:06 +0000
Message-ID: <BL2PR03MB5456EBFF6B39874ADE0F496E6000@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0374204325371700176=="
Cc: Scott Wood <scottwood@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "bhamciu1@freescale.com" <bhamciu1@freescale.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============0374204325371700176==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_BL2PR03MB5456EBFF6B39874ADE0F496E6000BL2PR03MB545namprd_"

--_000_BL2PR03MB5456EBFF6B39874ADE0F496E6000BL2PR03MB545namprd_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: Kumar Gala [mailto:galak@kernel.crashing.org]
>
> On Mar 17, 2015, at 1:58 PM, Madalin Bucur <madalin.bucur@Freescale.com>
> wrote:
>
> > This introduces the Freescale Data Path Acceleration Architecture
> > (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> > BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> > the Freescale DPAA QorIQ platforms.
> >
> > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> > ---

[snip]

> > diff --git a/drivers/net/ethernet/freescale/Makefile
> b/drivers/net/ethernet/freescale/Makefile
> > index 71debd1..b6c10ab 100644
> > --- a/drivers/net/ethernet/freescale/Makefile
> > +++ b/drivers/net/ethernet/freescale/Makefile
> > @@ -12,6 +12,7 @@ obj-$(CONFIG_FS_ENET) +=3D fs_enet/
> > obj-$(CONFIG_FSL_PQ_MDIO) +=3D fsl_pq_mdio.o
> > obj-$(CONFIG_FSL_XGMAC_MDIO) +=3D xgmac_mdio.o
> > obj-$(CONFIG_GIANFAR) +=3D gianfar_driver.o
> > +obj-$(if $(CONFIG_FSL_DPAA_ETH),y) +=3D dpaa/
>
> Why isn't
>
> obj-$(CONFIG_FSL_DPAA_ETH)            +=3D dpaa/
>
> enough?

It is, will fix.

> > diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig
> b/drivers/net/ethernet/freescale/dpaa/Kconfig
> > new file mode 100644
> > index 0000000..7ef703c
> > --- /dev/null
> > +++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
> > @@ -0,0 +1,49 @@
> > +menuconfig FSL_DPAA_ETH
> > +      tristate "DPAA Ethernet"
> > +      depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_FMAN
> > +      select PHYLIB
> > +      select FSL_FMAN_MAC
> > +      ---help---
> > +        Data Path Acceleration Architecture Ethernet driver,
> > +        supporting the Freescale QorIQ chips.
> > +        Depends on Freescale Buffer Manager and Queue Manager
> > +        driver and Frame Manager Driver.
> > +
> > +if FSL_DPAA_ETH
> > +
> > +config FSL_DPAA_CS_THRESHOLD_1G
> > +      hex "Egress congestion threshold on 1G ports"
> > +      depends on FSL_DPAA_ETH
> > +      range 0x1000 0x10000000
> > +      default "0x06000000"
> > +      ---help---
> > +        The size in bytes of the egress Congestion State notification
> threshold on 1G ports.
> > +        The 1G dTSECs can quite easily be flooded by cores doing Tx in=
 a
> tight loop
> > +        (e.g. by sending UDP datagrams at "while(1) speed"),
> > +        and the larger the frame size, the more acute the problem.
> > +        So we have to find a balance between these factors:
> > +             - avoiding the device staying congested for a prolonged t=
ime
> (risking
> > +                 the netdev watchdog to fire - see also the tx_timeout=
 module
> param);
> > +               - affecting performance of protocols such as TCP, which=
 otherwise
> > +               behave well under the congestion notification mechanism=
;
> > +             - preventing the Tx cores from tightly-looping (as if the
> congestion
> > +               threshold was too low to be effective);
> > +             - running out of memory if the CS threshold is set too hi=
gh.
> > +
> > +config FSL_DPAA_CS_THRESHOLD_10G
> > +      hex "Egress congestion threshold on 10G ports"
> > +      depends on FSL_DPAA_ETH
> > +      range 0x1000 0x20000000
> > +      default "0x10000000"
> > +      ---help ---
> > +        The size in bytes of the egress Congestion State notification
> threshold on 10G ports.
> > +
> > +config FSL_DPAA_INGRESS_CS_THRESHOLD
> > +      hex "Ingress congestion threshold on FMan ports"
> > +      depends on FSL_DPAA_ETH
> > +      default "0x10000000"
> > +      ---help---
> > +        The size in bytes of the ingress tail-drop threshold on FMan p=
orts.
> > +        Traffic piling up above this value will be rejected by QMan an=
d
> discarded by FMan.
> > +
>
> Do these thresholds really need to be kconfig options?  Are they not
> changeable at runtime?

Probably Bogdan thought it was an easy way to provide basic means to tweak =
them
and also provide some explanation for them. The current setting is chosen t=
o keep
them mostly out of the way but still address a corner case a customer repor=
ted, if
I remember correctly. No runtime change is supported.

> > diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile
> b/drivers/net/ethernet/freescale/dpaa/Makefile
> > new file mode 100644
> > index 0000000..bdeb04e
> > --- /dev/null
> > +++ b/drivers/net/ethernet/freescale/dpaa/Makefile
> > @@ -0,0 +1,14 @@
> > +#
> > +# Makefile for the Freescale DPAA Ethernet controllers
> > +#
> > +ccflags-y +=3D -DVERSION=3D\"\"
>
> Is this really needed, if so we need to fix that.

Unused, will remove.

[snip]
> > +
> > +#define DPA_DESCRIPTION "FSL DPAA Ethernet driver"
> > +
> > +MODULE_LICENSE("Dual BSD/GPL");
> > +
> > +MODULE_AUTHOR("Andy Fleming <afleming@freescale.com>");
> > +
> > +MODULE_DESCRIPTION(DPA_DESCRIPTION);
>
> These are typically at the end of the file, and kept together (ie no blan=
k lines
> between them)

Will move them.

[snip]
> > +
> > +static struct platform_device_id dpa_devtype[] =3D {
> > +      {
> > +                      .name =3D "dpaa-ethernet",
> > +                      .driver_data =3D 0,
> > +      }, {
> > +      }
> > +};
> > +MODULE_DEVICE_TABLE(platform, dpa_devtype);
> > +
> > +static struct platform_driver dpa_driver =3D {
> > +      .driver =3D {
> > +                      .name                   =3D KBUILD_MODNAME,
> > +                      .owner                 =3D THIS_MODULE,
> > +      },
> > +      .id_table              =3D dpa_devtype,
> > +      .probe                  =3D dpaa_eth_priv_probe,
> > +      .remove                               =3D dpa_remove
> > +};
> > +
> > +static int __init __cold dpa_load(void)
> > +{
> > +      int           _errno;
> > +
> > +      pr_info(DPA_DESCRIPTION " (" VERSION ")\n");
> > +
> > +      /* initialise dpaa_eth mirror values */
> > +      dpa_rx_extra_headroom =3D fm_get_rx_extra_headroom();
> > +      dpa_max_frm =3D fm_get_max_frm();
> > +
> > +      _errno =3D platform_driver_register(&dpa_driver);
> > +      if (unlikely(_errno < 0)) {
> > +                      pr_err(KBUILD_MODNAME
> > +                                      ": %s:%hu:%s(): platform_driver_=
register() =3D %d\n",
> > +                                      KBUILD_BASENAME ".c", __LINE__, =
__func__,
> _errno);
> > +      }
> > +
> > +      pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> > +                      KBUILD_BASENAME ".c", __func__);
> > +
> > +      return _errno;
> > +}
> > +module_init(dpa_load);
> > +
> > +static void __exit __cold dpa_unload(void)
> > +{
> > +      pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
> > +                      KBUILD_BASENAME ".c", __func__);
> > +
> > +      platform_driver_unregister(&dpa_driver);
> > +
> > +      /* Only one channel is used and needs to be relased after all
> > +      * interfaces are removed
> > +      */
> > +      dpa_release_channel();
> > +
> > +      pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> > +                      KBUILD_BASENAME ".c", __func__);
> > +}
> > +module_exit(dpa_unload);
>
> What's the point of this dpa platform driver?
>

It replaces the device tree node probing, based on the feedback [1] receive=
d from Scott.
The FMan MAC driver creates a device for the Ethernet driver to probe again=
st in
dpaa_eth_add_device(), see [2]. This replaces the rejected model where a co=
nfiguration
node for Ethernet was added to the device tree with a reference to the FMan=
 MAC node.
The platform device provides the Ethernet driver with FMan MAC identificati=
on and the
MAC dev needed back in the adjust_link() call:
...
struct dpaa_eth_data {
                struct device_node *mac_node;
                struct mac_device *mac_dev;
                int mac_hw_id;
                int fman_hw_id;
};
...
static void adjust_link(struct net_device *net_dev)
{
                struct device *dev =3D net_dev->dev.parent;
                struct dpaa_eth_data *eth_data =3D dev->platform_data;
                struct mac_device *mac_dev =3D eth_data->mac_dev;
...

[snip]
> > +static inline int __hot dpa_xmit(struct dpa_priv_s *priv,
> > +                                                      struct rtnl_link=
_stats64 *percpu_stats,
> > +                                                      int queue,
> > +                                                      struct qm_fd *fd=
)
>
> Is there a reason this isnt just in the .c file?
It's also used by the un-submitted advanced drivers that compile against th=
e
submitted code (there are a few other things used in common - such as the c=
ode
extracted in the dpaa_eth_common.c file).

> > +EXPORT_SYMBOL(dpa_mac_dev_get);
>
> why is this exported?
>

Same reason as above.

[snip]

Thank you for your time,
Madalin

[1] https://patchwork.ozlabs.org/patch/415831/
[2] https://patchwork.ozlabs.org/patch/448874/

--_000_BL2PR03MB5456EBFF6B39874ADE0F496E6000BL2PR03MB545namprd_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">&gt; -----Original Message-----<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; From: Kumar Gala [mailto:galak@kernel.crashing.=
org]<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; On Mar 17, 2015, at 1:58 PM, Madalin Bucur &lt;=
madalin.bucur@Freescale.com&gt;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; wrote:<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; This introduces the Freescale Data Path Ac=
celeration Architecture<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; (DPAA) Ethernet driver (dpaa_eth) that bui=
lds upon the DPAA QMan,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; BMan, PAMU and FMan drivers to deliver Eth=
ernet connectivity on<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; the Freescale DPAA QorIQ platforms.<o:p></=
o:p></p>
<p class=3D"MsoNormal">&gt; &gt;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; Signed-off-by: Madalin Bucur &lt;madalin.b=
ucur@freescale.com&gt;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; ---<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[snip]<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; diff --git a/drivers/net/ethernet/freescal=
e/Makefile<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; b/drivers/net/ethernet/freescale/Makefile<o:p><=
/o:p></p>
<p class=3D"MsoNormal">&gt; &gt; index 71debd1..b6c10ab 100644<o:p></o:p></=
p>
<p class=3D"MsoNormal">&gt; &gt; --- a/drivers/net/ethernet/freescale/Makef=
ile<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&#43;&#43; b/drivers/net/ethernet/fre=
escale/Makefile<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; @@ -12,6 &#43;12,7 @@ obj-$(CONFIG_FS_ENET=
) &#43;=3D fs_enet/<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; obj-$(CONFIG_FSL_PQ_MDIO) &#43;=3D fsl_pq_=
mdio.o<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; obj-$(CONFIG_FSL_XGMAC_MDIO) &#43;=3D xgma=
c_mdio.o<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; obj-$(CONFIG_GIANFAR) &#43;=3D gianfar_dri=
ver.o<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;obj-$(if $(CONFIG_FSL_DPAA_ETH),y) &#=
43;=3D dpaa/<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; Why isn&#8217;t<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; obj-$(CONFIG_FSL_DPAA_ETH)&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#43;=3D dpaa/<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; enough?<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">It is, will fix.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; diff --git a/drivers/net/ethernet/freescal=
e/dpaa/Kconfig<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; b/drivers/net/ethernet/freescale/dpaa/Kconfig<o=
:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; new file mode 100644<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; index 0000000..7ef703c<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; --- /dev/null<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&#43;&#43; b/drivers/net/ethernet/fre=
escale/dpaa/Kconfig<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; @@ -0,0 &#43;1,49 @@<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;menuconfig FSL_DPAA_ETH<o:p></o:p></p=
>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trista=
te &quot;DPAA Ethernet&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; depend=
s on FSL_SOC &amp;&amp; FSL_BMAN &amp;&amp; FSL_QMAN &amp;&amp; FSL_FMAN<o:=
p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; select=
 PHYLIB<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; select=
 FSL_FMAN_MAC<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---hel=
p---<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 Data Path Acceleration Architecture Ethernet driver,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 supporting the Freescale QorIQ chips.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 Depends on Freescale Buffer Manager and Queue Manager<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 driver and Frame Manager Driver.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;if FSL_DPAA_ETH<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;config FSL_DPAA_CS_THRESHOLD_1G<o:p><=
/o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; hex &q=
uot;Egress congestion threshold on 1G ports&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; depend=
s on FSL_DPAA_ETH<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; range =
0x1000 0x10000000<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; defaul=
t &quot;0x06000000&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---hel=
p---<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 The size in bytes of the egress Congestion State notification<o:p></o:p></=
p>
<p class=3D"MsoNormal">&gt; threshold on 1G ports.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 The 1G dTSECs can quite easily be flooded by cores doing Tx in a<o:p></o:p=
></p>
<p class=3D"MsoNormal">&gt; tight loop<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 (e.g. by sending UDP datagrams at &quot;while(1) speed&quot;),<o:p></o:p><=
/p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 and the larger the frame size, the more acute the problem.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 So we have to find a balance between these factors:<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - avoiding the device staying congested for =
a prolonged time<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; (risking<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; the netdev watc=
hdog to fire - see also the tx_timeout module<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; param);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - affecting performance of =
protocols such as TCP, which otherwise<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; behave well under the congestion=
 notification mechanism;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - preventing the Tx cores from tightly-loopi=
ng (as if the<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; congestion<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; threshold was too low to be effe=
ctive);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - running out of memory if the CS threshold =
is set too high.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;config FSL_DPAA_CS_THRESHOLD_10G<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; hex &q=
uot;Egress congestion threshold on 10G ports&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; depend=
s on FSL_DPAA_ETH<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; range =
0x1000 0x20000000<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; defaul=
t &quot;0x10000000&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---hel=
p ---<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 The size in bytes of the egress Congestion State notification<o:p></o:p></=
p>
<p class=3D"MsoNormal">&gt; threshold on 10G ports.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;config FSL_DPAA_INGRESS_CS_THRESHOLD<=
o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; hex &q=
uot;Ingress congestion threshold on FMan ports&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; depend=
s on FSL_DPAA_ETH<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; defaul=
t &quot;0x10000000&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ---hel=
p---<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 The size in bytes of the ingress tail-drop threshold on FMan ports.<o:p></=
o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;=
 Traffic piling up above this value will be rejected by QMan and<o:p></o:p>=
</p>
<p class=3D"MsoNormal">&gt; discarded by FMan.<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; Do these thresholds really need to be kconfig o=
ptions?&nbsp; Are they not<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; changeable at runtime?<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Probably Bogdan thought it was an easy way to provid=
e basic means to tweak them<o:p></o:p></p>
<p class=3D"MsoNormal">and also provide some explanation for them. The curr=
ent setting is chosen to keep<o:p></o:p></p>
<p class=3D"MsoNormal">them mostly out of the way but still address a corne=
r case a customer reported, if<o:p></o:p></p>
<p class=3D"MsoNormal">I remember correctly. No runtime change is supported=
.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; diff --git a/drivers/net/ethernet/freescal=
e/dpaa/Makefile<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; b/drivers/net/ethernet/freescale/dpaa/Makefile<=
o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; new file mode 100644<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; index 0000000..bdeb04e<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; --- /dev/null<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&#43;&#43; b/drivers/net/ethernet/fre=
escale/dpaa/Makefile<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; @@ -0,0 &#43;1,14 @@<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;#<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;# Makefile for the Freescale DPAA Eth=
ernet controllers<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;#<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;ccflags-y &#43;=3D -DVERSION=3D\&#822=
1;\&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; Is this really needed, if so we need to fix tha=
t.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Unused, will remove.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[snip]<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;#define DPA_DESCRIPTION &quot;FSL DPA=
A Ethernet driver&quot;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;MODULE_LICENSE(&quot;Dual BSD/GPL&quo=
t;);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;MODULE_AUTHOR(&quot;Andy Fleming &lt;=
afleming@freescale.com&gt;&quot;);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;MODULE_DESCRIPTION(DPA_DESCRIPTION);<=
o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; These are typically at the end of the file, and=
 kept together (ie no blank lines<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; between them)<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Will move them.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[snip]<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;static struct platform_device_id dpa_=
devtype[] =3D {<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; .name =3D &quot;dpaa-ethernet&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; .driver_data =3D 0,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }, {<o=
:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;};<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;MODULE_DEVICE_TABLE(platform, dpa_dev=
type);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;static struct platform_driver dpa_dri=
ver =3D {<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .drive=
r =3D {<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; .name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =3D KBUILD_MODNAME,<o=
:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; .owner&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =3D THIS_MODULE,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; },<o:p=
></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .id_ta=
ble&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; =3D dpa_devtype,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .probe=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; =3D dpaa_eth_priv_probe,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .remov=
e&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =3D dpa_remove<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;};<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;static int __init __cold dpa_load(voi=
d)<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;{<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _errno;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pr_inf=
o(DPA_DESCRIPTION &quot; (&quot; VERSION &quot;)\n&quot;);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* ini=
tialise dpaa_eth mirror values */<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dpa_rx=
_extra_headroom =3D fm_get_rx_extra_headroom();<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dpa_ma=
x_frm =3D fm_get_max_frm();<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _errno=
 =3D platform_driver_register(&amp;dpa_driver);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (un=
likely(_errno &lt; 0)) {<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; pr_err(KBUILD_MODNAME<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &quot;: %s:%hu:%s(): platform_driver_re=
gister() =3D %d\n&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; KBUILD_BASENAME &quot;.c&quot;, __LINE_=
_, __func__,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; _errno);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pr_deb=
ug(KBUILD_MODNAME &quot;: %s:%s() -&gt;\n&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; KBUILD_BASENAME &quot;.c&quot;, __func__);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return=
 _errno;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;}<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;module_init(dpa_load);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;static void __exit __cold dpa_unload(=
void)<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;{<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pr_deb=
ug(KBUILD_MODNAME &quot;: -&gt; %s:%s()\n&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; KBUILD_BASENAME &quot;.c&quot;, __func__);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; platfo=
rm_driver_unregister(&amp;dpa_driver);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Onl=
y one channel is used and needs to be relased after all<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * inte=
rfaces are removed<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; */<o:p=
></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dpa_re=
lease_channel();<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pr_deb=
ug(KBUILD_MODNAME &quot;: %s:%s() -&gt;\n&quot;,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; KBUILD_BASENAME &quot;.c&quot;, __func__);<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;}<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;module_exit(dpa_unload);<o:p></o:p></=
p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; What&#8217;s the point of this dpa platform dri=
ver?<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">It replaces the device tree node probing, based on t=
he feedback [1] received from Scott.<o:p></o:p></p>
<p class=3D"MsoNormal">The FMan MAC driver creates a device for the Etherne=
t driver to probe against in<o:p></o:p></p>
<p class=3D"MsoNormal">dpaa_eth_add_device(), see [2]. This replaces the re=
jected model where a configuration<o:p></o:p></p>
<p class=3D"MsoNormal">node for Ethernet was added to the device tree with =
a reference to the FMan MAC node.<o:p></o:p></p>
<p class=3D"MsoNormal">The platform device provides the Ethernet driver wit=
h FMan MAC identification and the<o:p></o:p></p>
<p class=3D"MsoNormal">MAC dev needed back in the adjust_link() call:<o:p><=
/o:p></p>
<p class=3D"MsoNormal">...<o:p></o:p></p>
<p class=3D"MsoNormal">struct dpaa_eth_data {<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct device_node *mac_node;<o:p></=
o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct mac_device *mac_dev;<o:p></o:=
p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int mac_hw_id;<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int fman_hw_id;<o:p></o:p></p>
<p class=3D"MsoNormal">};<o:p></o:p></p>
<p class=3D"MsoNormal">...<o:p></o:p></p>
<p class=3D"MsoNormal">static void adjust_link(struct net_device *net_dev)<=
o:p></o:p></p>
<p class=3D"MsoNormal">{<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct device *dev =3D net_dev-&gt;d=
ev.parent;<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct dpaa_eth_data *eth_data =3D d=
ev-&gt;platform_data;<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct mac_device *mac_dev =3D eth_d=
ata-&gt;mac_dev;<o:p></o:p></p>
<p class=3D"MsoNormal">...<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[snip]<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;static inline int __hot dpa_xmit(stru=
ct dpa_priv_s *priv,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct rtnl_link_s=
tats64 *percpu_stats,<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int queue,<o:p></o=
:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct qm_fd *fd)<=
o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; Is there a reason this isnt just in the .c file=
?<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">It's also used by the un-submitted advanced drivers =
that compile against the<o:p></o:p></p>
<p class=3D"MsoNormal">submitted code (there are a few other things used in=
 common - such as the code<o:p></o:p></p>
<p class=3D"MsoNormal">extracted in the dpaa_eth_common.c file).<o:p></o:p>=
</p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&gt; &gt; &#43;EXPORT_SYMBOL(dpa_mac_dev_get);<o:p><=
/o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal">&gt; why is this exported?<o:p></o:p></p>
<p class=3D"MsoNormal">&gt; <o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Same reason as above.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[snip]<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Thank you for your time,<o:p></o:p></p>
<p class=3D"MsoNormal">Madalin<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">[1] https://patchwork.ozlabs.org/patch/415831/<o:p><=
/o:p></p>
<p class=3D"MsoNormal">[2] https://patchwork.ozlabs.org/patch/448874/<o:p><=
/o:p></p>
</div>
</body>
</html>

--_000_BL2PR03MB5456EBFF6B39874ADE0F496E6000BL2PR03MB545namprd_--

--===============0374204325371700176==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============0374204325371700176==--
