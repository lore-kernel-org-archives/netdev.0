From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: lookup switch name
Date: Fri, 30 Oct 2015 17:01:51 -0400
Message-ID: <20151030210151.GA10286@ketchup.mtl.sfl>
References: <1446237416-5447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151030205258.GC10053@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151030205258.GC10053@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct. Friday 30 (44) 09:52 PM, Andrew Lunn wrote:
> On Fri, Oct 30, 2015 at 04:36:56PM -0400, Vivien Didelot wrote:
> > All the mv88e6xxx drivers use the exact same code in their probe
> > function to lookup the switch name given its ID.
> 
> I did consider this before. But they are not exactly the same, when
> you consider the masking of the lower nibble which some drivers do,
> and others not. But i see you handled that.
> 
> > +char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
> > +			    const struct mv88e6xxx_switch_id *table,
> > +			    unsigned int num)
> > +{
> > +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> > +	int i, ret;
> > +
> > +	if (!bus)
> > +		return NULL;
> > +
> > +	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
> > +	if (ret < 0)
> > +		return NULL;
> > +
> > +	/* Look up the exact switch ID */
> > +	for (i = 0; i < num; ++i) {
> > +		if (table[i].id == ret) {
> > +			pr_info("found switch 0x%x\n", ret);
> 
> The old code did not print anything. The core DSA will print it later
> however, so we don't need to print it here.

Indeed, not very useful and redundant with the one from DSA...

> 
> > +			return table[i].name;
> > +		}
> > +	}
> > +
> > +	/* Look up only the product number */
> > +	for (i = 0; i < num; ++i) {
> > +		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
> > +			pr_warn("found switch 0x%x, maybe register rev %d?\n",
> > +				ret, ret & PORT_SWITCH_ID_REV_MASK);
> 
> I probably would not warn here. The old code did not.

The old code did not, but it silently fell back to checking only the
product number. I found this useful to motivate the user to define this
new revision. Does it makes sense, or should I remove the warning?

> Apart from these comments, a good change.

Thanks!
-v
