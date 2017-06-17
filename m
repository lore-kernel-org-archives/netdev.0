From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 17 Jun 2017 11:56:02 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2CF8@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-7-salil.mehta@huawei.com>
 <20170614024234.GB16215@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614024234.GB16215@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 3:43 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to
> HNS3 Ethernet driver for hip08 SoC
> 
> > +struct hclge_mdio_cfg_cmd {
> > +	u8 ctrl_bit;
> > +	u8 prtad;       /* The external port address */
> > +	u8 devad;       /* The external device address */
> > +	u8 rsvd;
> > +	__le16 addr_c45;/* Only valid for c45 */
> > +	__le16 data_wr;
> > +	__le16 data_rd;
> > +	__le16 sta;
> > +};
> > +
> > +static int hclge_mdio_write(struct mii_bus *bus, int phy_id, int
> regnum,
> > +			    u16 data)
> > +{
> > +	struct hclge_dev *hdev = (struct hclge_dev *)bus->priv;
> > +	struct hclge_mdio_cfg_cmd *mdio_cmd;
> > +	enum hclge_cmd_status status;
> > +	struct hclge_desc desc;
> > +	u8 is_c45, devad;
> > +	u16 reg;
> > +
> > +	if (!bus)
> > +		return -EINVAL;
> > +
> > +	is_c45 = !!(regnum & MII_ADDR_C45);
> > +	devad = ((regnum >> 16) & 0x1f);
> > +	reg = (u16)(regnum & 0xffff);
> > +
> > +	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MDIO_CONFIG, false);
> > +
> > +	mdio_cmd = (struct hclge_mdio_cfg_cmd *)desc.data;
> > +
> > +	mdio_cmd->ctrl_bit |= HCLGE_MDIO_CTRL_START_BIT;
> > +	mdio_cmd->prtad = phy_id & HCLGE_MDIO_CTRL_PRTAD_MSK;
> > +	mdio_cmd->data_wr = cpu_to_le16(data);
> > +	mdio_cmd->devad = devad & HCLGE_MDIO_CTRL_DEVAD_MSK;
> > +
> > +	if (is_c45) {
> > +		/* Set phy addr */
> > +		mdio_cmd->addr_c45 = cpu_to_le16(reg);
> > +	} else {
> > +		/* C22 write reg and data */
> > +		mdio_cmd->ctrl_bit = HCLGE_MDIO_IS_C22(!is_c45);
> > +		mdio_cmd->ctrl_bit |=
> HCLGE_MDIO_CTRL_OP(HCLGE_MDIO_C22_WRITE);
> > +	}
> 
> When doing C22, i don't see you putting the reg into mdio_cmd anywhere?
>
You are right. Will remove.

Thanks
Salil 
> Also
> 
> 	mdio_cmd->ctrl_bit = HCLGE_MDIO_IS_C22(!is_c45);
> 
> can be pulled of the if/then/else since it takes is_c45 as a
> parameter, or simplified.
> 
>      Andrew
Sure, thanks will do.

Salil
