From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: create drivers/net/mdio and move mdio drivers into it
Date: Mon, 20 Feb 2017 05:23:46 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:55832 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750737AbdBTFYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 00:24:21 -0500
In-Reply-To: <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. the main issue is mdio driver mixed with phy driver/ethernet driver.
2. move them together, it's easy to maintain, add, delete or optimization(we can do it step by step).

3. another idea is bind mdio device to network device
4. support mdio auto probe phy device.
For 3, 4 can take device tree as example,
Current,
			ethernet@e4000 {
				phy-handle = <&rgmii_phy1>;
				phy-connection-type = "rgmii";
			};

			ethernet@e6000 {
				phy-handle = <&rgmii_phy2>;
				phy-connection-type = "rgmii";
			};

			mdio@fc000 {
				rgmii_phy1: ethernet-phy@1 {
					reg = <0x1>;
				};
				rgmii_phy2: ethernet-phy@2 {
					reg = <0x2>;
				};
			};
After change,
			ethernet@e4000 {
				mdio-handle = <&mdio>;
				phy-reg = <0x1>;
				phy-connection-type = "rgmii";
			};

			ethernet@e6000 {
				mdio-handle = <&mdio>;
				phy-handle = <&rgmii_phy2>;
				phy-connection-type = "rgmii";
			};

			mdio: mdio@fc000 {
			    reg = <xxx>;
			};


> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Monday, February 20, 2017 1:03 PM
> To: YUAN Linyu; David S . Miller; Andrew Lunn
> Cc: netdev@vger.kernel.org; cugyly@163.com
> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> 
> 
> 
> On 02/19/2017 04:20 PM, YUAN Linyu wrote:
> > Hi,
> >
> > I have an idea to create drivers/net/mdio and move mdio
> drivers(drivers/net/phy/mdio-* | drivers/net/ethernet/xxx/mdio-yyy | ) into it.
> >
> > Do you think it is acceptable ?
> 
> What problem are you trying to fix by doing such a move? Moving files
> around mean that making stable backports are going to be much more painful.
> 
> So without further explanation, does not sound like such a great idea.
> --
> Florian
