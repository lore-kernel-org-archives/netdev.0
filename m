From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v5] ethernet/arc/arc_emac - Add new driver
Date: Thu, 20 Jun 2013 10:16:04 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5F30BF@DE02WEMBXB.internal.synopsys.com>
References: <1371629537-8076-1-git-send-email-abrodkin@synopsys.com>
 <CAHp75Vc-Aza03ZLJj3CkLP2YhvdRi94bfutxKbV34hTc1_6k4g@mail.gmail.com>
 <4881796E12491D4BB15146FE0209CE643F5F2F56@DE02WEMBXB.internal.synopsys.com>
 <CAGVrzcYoz-pGG46otLjZDHs=xek-qpPEWxUtDQV1CcWCPs8WYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2013 01:57 PM, Florian Fainelli wrote:
> 2013/6/20 Alexey Brodkin <Alexey.Brodkin@synopsys.com>:
> [snip]
>
>>
>> In general MDIO register gets polled by "libphy" once in a couple of
>> seconds, so delay of 25 milliseconds IMHO is fine.
>>
>>>> +int arc_mdio_probe(struct device_node *dev_node, struct arc_emac_priv *priv)
>>>> +{
>>>
>>>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x", (unsigned int)priv->regs);
>>>
>>> Is bus->id exposed to user-space somehow?
>>
>> Well as a boot-up message from "libphy":
>> ====
>> libphy: Synopsys MII Bus: probed
>> ====
>
> Well not only as a boot-up message, this serves as unique identifer in
> the entire system for your MDIO bus. It is crucial that you have an
> unique MDIO bus identifier for at least the two following reasons:
>
> - the corresponding kobject/sysfs node that is going to be created
> also needs to be unique in the system
> - you may have multiple MDIO bus in the system (e.g: the one for your
> specific driver and the fixed MDIO bus)

Good explanation. I didn't realize it yet.
And it seems like I talked about bus "name", not "id".

> Since you are using Device Tree already, you may just turn this into:
>
> snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
>
> assuming that your node is already properly labelleled (e.g:
> mdio@deadbeef) which would be exactly equivalent to what you are doing
> with priv->regs;

The thing is I don't have separate "mdio" device description in DT.
Regs value is read from "ethernet" device description.

Here's my DT entry for entire emac:
=============
		ethernet@c0fc2000 {
			compatible = "snps,arc-emac";
			reg = <0xc0fc2000 0x3c>;
			interrupts = <6>;
			mac-address = [ 00 11 22 33 44 55 ];
			clock-frequency = <80000000>;
			max-speed = <100>;
			phy = <&phy0>;

			#address-cells = <1>;
			#size-cells = <0>;
			phy0: ethernet-phy@0 {
				reg = <1>;
			};
		};
=============

So with your proposal bus id will be just "ethernet" which is not that 
unique, right?

That's why address of registers IMHO fits better to a bus id.

-Alexey
