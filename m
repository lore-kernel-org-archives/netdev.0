From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: smsc: Fix disabling energy detect mode
Date: Tue, 19 Jan 2016 14:31:34 -0500 (EST)
Message-ID: <20160119.143134.622696308505132405.davem@davemloft.net>
References: <1453190199-22269-1-git-send-email-t.remmet@phytec.de>
	<20160119152503.GK6554@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: t.remmet@phytec.de, netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160119152503.GK6554@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 19 Jan 2016 16:25:03 +0100

>> +struct smsc_phy_priv {
>> +	bool energy_enable:1;
>> +};
> 
> Time to show my ignorance of bitfields. Since this is a bool, does the
> :1 actually do anything?

Even if does something, saving space for a datastructure like this makes
no sense.  There are no adjacent bit fields to share the space with.

Just use plain 'bool'.

>> +static int smsc_phy_probe(struct phy_device *phydev)
>> +{
>> +	struct device *dev = &phydev->mdio.dev;
>> +	struct device_node *of_node __maybe_unused = dev->of_node;
>> +	struct smsc_phy_priv *priv;
>> +	int __maybe_unused len;
>> +
>> +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
>> +	if (!priv)
>> +		return -ENOMEM;
>> +
>> +	if (of_find_property(of_node, "smsc,disable-energy-detect", &len))
>> +		priv->energy_enable = false;
> 
> Here you set it to false. Where does it get set to true?
> 
> Also, of_property_read_bool() would be a better call than of_find_property.

Yeah this looks broken to me too.
