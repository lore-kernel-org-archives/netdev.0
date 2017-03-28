From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Tue, 28 Mar 2017 13:51:30 +0800
Message-ID: <1490680290.14184.28.camel@mtkswgap22>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
 <842616ad-1e04-9e56-3137-dd8aed1dd896@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org,
 keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <842616ad-1e04-9e56-3137-dd8aed1dd896-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Thank for taking your time on reviewing. Add comment as inline.

On Wed, 2017-03-22 at 11:39 -0700, Florian Fainelli wrote:
> On 03/21/2017 02:35 AM, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> > From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> > 
> > MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
> > Mediatek router platforms such as MT7623A or MT7623N platform which
> > includes 7-port Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY.
> > Among these ports, The port from 0 to 4 are the user ports connecting
> > with the remote devices while the port 5 and 6 are the CPU ports
> > connecting into Mediatek Ethernet GMAC.
> > 
> > For port 6, it can communicate with the CPU via Mediatek Ethernet GMAC
> > through either the TRGMII or RGMII which could be controlled by phy-mode
> > in the dt-bindings to specify which mode is preferred to use. And for
> > port 5, only RGMII can be specified. However, currently, only port 6 is
> > being supported in this DSA driver.
> > 
> > The driver is made with the reference to qca8k and other existing DSA
> > driver. The most of the essential callbacks of the DSA are already
> > support in the driver, including tag insert for user port distinguishing,
> > port control, bridge offloading, STP setup and ethtool operation to allow
> > DSA to model each user port into a standalone netdevice as the other DSA
> > driver had done.
> 
> Overall, this looks pretty nice and clean, a few comments below
> 
> > 
> > Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> > Signed-off-by: Landen Chao <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> > ---
> 
> > +static void
> > +mt7530_fdb_read(struct mt7530_priv *priv, struct mt7530_fdb *fdb)
> > +{
> > +	u32 reg[3];
> > +	int i;
> > +
> > +	/* Read from ARL table into an array */
> > +	for (i = 0; i < 3; i++) {
> > +		reg[i] = mt7530_read(priv, MT7530_TSRA1 + (i * 4));
> > +
> > +		dev_dbg(priv->dev, "%s(%d) reg[%d]=0x%x\n",
> > +			__func__, __LINE__, i, reg[i]);
> > +	}
> > +
> > +	/* vid - 11:0 on reg[1] */
> > +	fdb->vid = (reg[1] >> 0) & 0xfff;
> > +	/* aging - 31:24 on reg[2] */
> > +	fdb->aging = (reg[2] >> 24) & 0xff;
> > +	/* portmask - 11:4 on reg[2] */
> > +	fdb->port_mask = (reg[2] >> 4) & 0xff;
> > +	/* mac - 31:0 on reg[0] and 31:16 on reg[1] */
> > +	fdb->mac[0] = (reg[0] >> 24) & 0xff;
> > +	fdb->mac[1] = (reg[0] >> 16) & 0xff;
> > +	fdb->mac[2] = (reg[0] >>  8) & 0xff;
> > +	fdb->mac[3] = (reg[0] >>  0) & 0xff;
> > +	fdb->mac[4] = (reg[1] >> 24) & 0xff;
> > +	fdb->mac[5] = (reg[1] >> 16) & 0xff;
> > +	/* noarp - 3:2 on reg[2] */
> > +	fdb->noarp = ((reg[2] >> 2) & 0x3) == STATIC_ENT;
> 
> Could you add some definitions for the bits and masks that you are
> shifting here?
> 

Okay, I'll make into proper macro for readability  

> > +}
> > +
> > +static void
> > +mt7530_fdb_write(struct mt7530_priv *priv, u16 vid,
> > +		 u8 port_mask, const u8 *mac,
> > +		 u8 aging, u8 type)
> > +{
> > +	u32 reg[3] = { 0 };
> > +	int i;
> > +
> > +	/* vid - 11:0 on reg[1] */
> > +	reg[1] |= (vid & 0xfff) << 0;
> > +	/* aging - 31:25 on reg[2] */
> > +	reg[2] |= (aging & 0xff) << 24;
> > +	/* portmask - 11:4 on reg[2] */
> > +	reg[2] |= (port_mask & 0xff) << 4;
> > +	/* type - 3 indicate that entry is static wouldn't
> > +	 * be aged out and 0 specified as erasing an entry
> > +	 */
> > +	reg[2] |= (type & 0x3) << 2;
> > +	/* mac - 31:0 on reg[0] and 31:16 on reg[1] */
> > +	reg[1] |= mac[5] << 16;
> > +	reg[1] |= mac[4] << 24;
> > +	reg[0] |= mac[3] << 0;
> > +	reg[0] |= mac[2] << 8;
> > +	reg[0] |= mac[1] << 16;
> > +	reg[0] |= mac[0] << 24;
> > +
> > +	/* Wrirte array into the ARL table */
> > +	for (i = 0; i < 3; i++)
> > +		mt7530_write(priv, MT7530_ATA1 + (i * 4), reg[i]);
> > +}
> 
> Same here.
> 

As above. I will improve them.


> > +
> > +static int
> > +mt7530_pad_clk_setup(struct dsa_switch *ds, int mode)
> > +{
> > +	struct mt7530_priv *priv = ds->priv;
> > +	u32 ncpo1, ssc_delta, trgint, i;
> > +
> > +	switch (mode) {
> > +	case PHY_INTERFACE_MODE_RGMII:
> > +		trgint = 0;
> > +		ncpo1 = 0x0c80;
> > +		ssc_delta = 0x87;
> > +		break;
> > +	case PHY_INTERFACE_MODE_TRGMII:
> > +		trgint = 1;
> > +		ncpo1 = 0x1400;
> > +		ssc_delta = 0x57;
> > +		break;
> > +	default:
> > +		pr_err("xMII mode %d not supported\n", mode);
> > +		return -EINVAL;
> > +	}
> 
> You may be able to move this to an adjust_link callback that the PHY
> library would call when the PHY gets setup and the port is finally used,
> as opposed to doing this upfront during driver initialization.
> 


Good point. i will follow up


> 
> > +mt7530_setup(struct dsa_switch *ds)
> > +{
> > +	struct mt7530_priv *priv = ds->priv;
> > +	int ret, i, phy_mode;
> > +	u8  cpup_mask = 0;
> > +	u32 id, val;
> > +	struct regmap *regmap;
> > +	struct device_node *dn;
> > +
> > +	/* Make sure that cpu port specfied on the dt is appropriate */
> > +	if (!dsa_is_cpu_port(ds, MT7530_CPU_PORT)) {
> > +		dev_err(priv->dev, "port not matched with the CPU port\n");
> > +		return -EINVAL;
> > +	}
> 
> This is kind of a hard error, in that case, a sensible thing to do could
> be issue a warning to the user telling that the configuration does not
> permit the use of Mediatek tags. Your get_tag_protocol() function could
> then return DSA_TAG_PROTO_NONE here instead of DSA_TAG_PROTO_MTK. It
> would still allow an user to utilize the switch, and we would know what
> is wrong with the configuration/board setup though.
> 

I seems making a hard requirement.

I will improve it with showing warning message if the number of cpu port
is not right.

It at least allows the other user ports can work in case cpu port
doesn't work.


> > +
> > +	/* The parent node of master_netdev which holds the common system
> > +	 * controller also is the container for two GMACs nodes representing
> > +	 * as two netdev instances.
> > +	 */
> > +	dn = ds->master_netdev->dev.of_node->parent;
> > +	priv->ethernet = syscon_node_to_regmap(dn);
> > +	if (IS_ERR(priv->ethernet))
> > +		return PTR_ERR(priv->ethernet);
> > +
> > +	regmap = devm_regmap_init(ds->dev, NULL, priv,
> > +				  &mt7530_regmap_config);
> > +	if (IS_ERR(regmap))
> > +		dev_warn(priv->dev, "phy regmap initialization failed");
> > +
> > +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> > +	if (phy_mode < 0) {
> > +		dev_err(priv->dev, "Can't find phy-mode for master device\n");
> > +		return phy_mode;
> > +	}
> > +	dev_info(priv->dev, "phy-mode for master device = %x\n", phy_mode);
> 
> An adjust_link() callback which has a proper PHY device structure would
> be more appropriate to look up the phy_mode rather than doing this here.
> 

As above. I will follow up 

> [snip]
> 
> > +	mt7530_clear(priv, MT7530_MFC, UNU_FFP_MASK);
> > +
> > +	/* Fabric setup for the cpu port */
> > +	for (i = 0; i < MT7530_NUM_PORTS; i++)
> 
> Are not you missing an opening parenthesis here in the for() statement?
> 

It is missing because the following is single statement. 
I admits it is better to add the parenthesis for readability, so I will
add it.

> > +		if (dsa_is_cpu_port(ds, i)) {
> > +			/* Enable Mediatek header mode on the cpu port */
> > +			mt7530_write(priv, MT7530_PVC_P(i),
> > +				     PORT_SPEC_TAG);
> > +
> > +			/* Setup the MAC by default for the cpu port */
> > +			mt7530_write(priv, MT7530_PMCR_P(i), PMCR_CPUP_LINK);
> > +
> > +			/* Disable auto learning on the cpu port */
> > +			mt7530_set(priv, MT7530_PSC_P(i), SA_DIS);
> > +
> > +			/* Unknown unicast frame fordwarding to the cpu port */
> > +			mt7530_set(priv, MT7530_MFC, UNU_FFP(BIT(i)));
> > +
> > +			/* CPU port gets connected to all user ports of
> > +			 * the switch
> > +			 */
> > +			mt7530_write(priv, MT7530_PCR_P(i),
> > +				     PCR_MATRIX(ds->enabled_port_mask));
> > +
> > +			cpup_mask |= BIT(i);
> > +		}
> > +
> > +	/* Fabric setup for the all user ports */
> > +	for (i = 0; i < MT7530_NUM_PORTS; i++)
> > +		if (ds->enabled_port_mask & BIT(i)) {
> > +			/* Setup the MAC by default for all user ports */
> > +			mt7530_write(priv, MT7530_PMCR_P(i),
> > +				     PMCR_USERP_LINK);
> > +
> > +			/* The user port gets connected to the cpu port only */
> > +			mt7530_write(priv, MT7530_PCR_P(i),
> > +				     PCR_MATRIX(cpup_mask));
> > +		}
> 
> This should be moved to the port_enable() function.
> 

okay. i will follow up.

> [snip]
*_poll_timeout
> > +#define wait_condition_timeout(condition, timeout)			\
> > +({									\
> > +	long __ret = 0;							\
> > +	unsigned long toj;						\
> > +	toj = jiffies + msecs_to_jiffies(timeout);			\
> > +									\
> > +	for ( ; !(condition) && !time_after_eq(jiffies, toj) ; )	\
> > +		cond_resched();						\
> > +									\
> > +	if (time_after_eq(jiffies, toj))				\
> > +		__ret = -ETIMEDOUT;					\
> > +	__ret;								\
> > +})
> 
> Can you use read*_poll_timeout() instead of this?
> 

I will try to reuse them

the function pointer for op in *_poll_timeout seems only accepting
only single argument for address. which implies I need creating another
function for mt7530_readX() used by *_poll_timeout and keeping another
static pointer to mt7530 internal for mt7530_readX() to work.


> > +/* struct mt7530_priv -	This is the main datasructure for holding the state
> > + *			of the driver
> > + * @dev:		The device pointer
> > + * @ds:			The pointer to the dsa core structure
> > + * @bus:		The bus used for the device and built-in PHY
> > + * @ethsys:		The regmap used for enabling the necessary PLL
> > + * @ethernet:		The regmap used for access TRGMII-based registers
> > + * @core_pwr:		The power supplied into the core
> > + * @io_pwr:		The power supplied into the I/O
> > + * @mcm:		Flag for distinguishing if standalone IC or module
> > + *			coupling
> > + * @reset:		The descriptor for GPIO line tied to its reset pin
> > + * @phy_mode:		The xMII for cpu port used
> > + * @ports:		Holding the state amongs ports
> > + * @reg_mutex:		The lock for protecting among process accessing
> > + *			registers
> > + */
> 
> Kudos for using kernel doc here.
