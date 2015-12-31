From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Thu, 31 Dec 2015 17:03:57 -0600
Message-ID: <CAL_Jsq+friyqL8ENx0aai8Mj5AjAGgToK9j_O_KiJfGTYzfW-Q@mail.gmail.com>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org>
 <566F6F3D.5050004@gmail.com> <20151215154904.559bd0cb@gavidov-lnx.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Timur Tabi <timur@codeaurora.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org
To: Gilad Avidov <gavidov@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20151215154904.559bd0cb@gavidov-lnx.qualcomm.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 4:49 PM, Gilad Avidov <gavidov@codeaurora.org> wrote:
> On Mon, 14 Dec 2015 17:39:09 -0800
> Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>> On 14/12/15 16:19, Gilad Avidov wrote:
>>
>> [snip]
>>
>> > +                   "sgmii_irq";
>> > +           qcom,emac-gpio-mdc = <&msmgpio 123 0>;
>> > +           qcom,emac-gpio-mdio = <&msmgpio 124 0>;
>> > +           qcom,emac-tstamp-en;
>> > +           qcom,emac-ptp-frac-ns-adj = <125000000 1>;
>> > +           phy-addr = <0>;
>>
>> Please use the standard Ethernet PHY and MDIO device tree bindings to
>> describe your MAC to PHY connection here, that includes using a
>> phy-connection-type property to describe the (x)MII lanes.
>>
>
>
> Hi Florian,
>
> Thank you for the review.
>
> Unfortunately this Ethernet controller's PHY is non standard and fits
> poorly into the standard MDIO framework layer. Rather than read/writs
> over MDIO only, this hw have some of the PHY registers internal and
> accessed by memory mapped IO, while others are accessed over the MDIO.
> Some standard functions requires using both. Additionally a number
> of different functions are controlled from different fields of the
> same register.

Even so, the bindings should follow the standard binding for MDIO bus
whether you can use the common kernel infrastructure or not.

Having internal phy connected to external phy is pretty common for
10G. Not sure if that is what you mean here or not.

Rob
