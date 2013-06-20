From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v5] ethernet/arc/arc_emac - Add new driver
Date: Thu, 20 Jun 2013 11:36:36 +0100
Message-ID: <CAGVrzcZL3LYDeqCfBK-rLHuvWrAYfLRE1puJcqTjuEPyFKTo9w@mail.gmail.com>
References: <1371629537-8076-1-git-send-email-abrodkin@synopsys.com>
 <CAHp75Vc-Aza03ZLJj3CkLP2YhvdRi94bfutxKbV34hTc1_6k4g@mail.gmail.com>
 <4881796E12491D4BB15146FE0209CE643F5F2F56@DE02WEMBXB.internal.synopsys.com>
 <CAGVrzcYoz-pGG46otLjZDHs=xek-qpPEWxUtDQV1CcWCPs8WYg@mail.gmail.com>
 <4881796E12491D4BB15146FE0209CE643F5F30BF@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
 Devicetree Discuss <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vineet Gupta <Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
 Mischa Jonker <Mischa.Jonker-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
To: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5F30BF-okAzG6w2b9vBRDCkatnZjvufCSb+aD3WLzEdoUbNIic@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

2013/6/20 Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>:
> On 06/20/2013 01:57 PM, Florian Fainelli wrote:
>> 2013/6/20 Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>:
>> [snip]
>>
>>>
>>> In general MDIO register gets polled by "libphy" once in a couple of
>>> seconds, so delay of 25 milliseconds IMHO is fine.
>>>
>>>>> +int arc_mdio_probe(struct device_node *dev_node, struct arc_emac_priv *priv)
>>>>> +{
>>>>
>>>>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x", (unsigned int)priv->regs);
>>>>
>>>> Is bus->id exposed to user-space somehow?
>>>
>>> Well as a boot-up message from "libphy":
>>> ====
>>> libphy: Synopsys MII Bus: probed
>>> ====
>>
>> Well not only as a boot-up message, this serves as unique identifer in
>> the entire system for your MDIO bus. It is crucial that you have an
>> unique MDIO bus identifier for at least the two following reasons:
>>
>> - the corresponding kobject/sysfs node that is going to be created
>> also needs to be unique in the system
>> - you may have multiple MDIO bus in the system (e.g: the one for your
>> specific driver and the fixed MDIO bus)
>
> Good explanation. I didn't realize it yet.
> And it seems like I talked about bus "name", not "id".
>
>> Since you are using Device Tree already, you may just turn this into:
>>
>> snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
>>
>> assuming that your node is already properly labelleled (e.g:
>> mdio@deadbeef) which would be exactly equivalent to what you are doing
>> with priv->regs;
>
> The thing is I don't have separate "mdio" device description in DT.
> Regs value is read from "ethernet" device description.
>
> Here's my DT entry for entire emac:
> =============
>                 ethernet@c0fc2000 {
>                         compatible = "snps,arc-emac";
>                         reg = <0xc0fc2000 0x3c>;
>                         interrupts = <6>;
>                         mac-address = [ 00 11 22 33 44 55 ];
>                         clock-frequency = <80000000>;
>                         max-speed = <100>;
>                         phy = <&phy0>;
>
>                         #address-cells = <1>;
>                         #size-cells = <0>;
>                         phy0: ethernet-phy@0 {
>                                 reg = <1>;
>                         };
>                 };
> =============
>
> So with your proposal bus id will be just "ethernet" which is not that
> unique, right?

No, it would be c0fc2000, which is, so we are just fine. Drivers that
support DT instantiation or platform_device/driver should in general
use <pdev->name>-<pdev->id> which works fine in both cases.
--
Florian
