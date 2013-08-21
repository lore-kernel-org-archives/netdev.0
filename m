From: Joe Perches <joe@perches.com>
Subject: Re: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700
 DeviceDriver into the Linux Kernel
Date: Wed, 21 Aug 2013 04:34:05 -0700
Message-ID: <1377084845.1936.26.camel@joe-AO722>
References: <201308201841116403992@163.com>
	 , <20130820204606.GB26241@electric-eye.fr.zoreil.com>
	 , <1377032302.2016.75.camel@joe-AO722> <201308211807295009698@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, gregkh <gregkh@suse.de>,
	sunhecheng <sunhecheng@vip.126.com>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: liujunliang_ljl <liujunliang_ljl@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201308211807295009698@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-21 at 18:07 +0800, liujunliang_ljl wrote:
> 		Thanks a lot and I have been fixed all the problems mentioned above. please check the following patch and thanks again. 

Just trivial comments below:

> diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
[]
> +static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
> +{
> +	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
> +					value, reg, NULL, 0);
> +}
> +
> +static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
> +{
[]
> +	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
> +	       phy, reg, *value, ret);

You have a lot of code that uses inconsistent
indentation.  Code in drivers/net and drivers/usb/net
generally prefers to use alignment to parenthesis for
multi-line statements

The first could use

	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
			       value, reg, NULL, 0);

and the second

	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
		   phy, reg, *value, ret);

Maximal use of 8 space indentation tabs followed by
minimal spaces.

There are many of these above.

> +static int sr9700_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom, u8 *data)
[]
> +	for (i = 0; i < eeprom->len / 2; i++)
> +			ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i, &ebuf[i]);

One too many tabs for the second line, a few of these...

[]

> +static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
[]
> +	if (rc == 1)
> +			return le16_to_cpu(res) | BMSR_LSTATUS;
> +	else
> +			return le16_to_cpu(res) & ~BMSR_LSTATUS;

The code below the returns here is unreachable.

> +
> +	netdev_dbg(dev->net,
> +	       "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
> +	       phy_id, loc, le16_to_cpu(res));
> +
> +	return le16_to_cpu(res);
> +}

You might try to use scripts/checkpatch.pl --strict if you
care about these.  It should flag most of these coding
style inconsistencies.
