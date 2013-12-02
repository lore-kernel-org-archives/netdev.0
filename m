From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH RFC 08/10] net: stmmac:sti: Add STi SOC glue driver.
Date: Mon, 2 Dec 2013 12:48:24 +0000
Message-ID: <529C8198.7000106@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com> <1384264383-7653-1-git-send-email-srinivas.kandagatla@st.com> <20131129193715.GA3441@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20131129193715.GA3441@lukather>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Maxime,

Thankyou for the comments.

On 29/11/13 19:37, Maxime Ripard wrote:
>> +
>> > +ethernet0: ethernet0{
>> > +	#address-cells = <1>;
>> > +	#size-cells = <1>;
>> > +	compatible		= "st,stih415-dwmac";
>> > +	reg			= <0x148 0x4>;
>> > +	resets			= <&softreset STIH415_ETH0_SOFTRESET>;
>> > +	st,syscon		= <&syscfg_rear>;
>> > +	st,tx-retime-src	= "clk_125";
>> > +	ranges;
>> > +
>> > +	dwmac0:dwmac@fe810000 {
>> > +		device_type 	= "network";
>> > +		compatible	= "snps,dwmac", "snps,dwmac-3.610";
>> > +		reg 		= <0xfe810000 0x8000>;
>> > +		interrupts 	= <0 147 0>;
>> > +		interrupt-names = "macirq";
>> > +		...
>> > +	};
>> > +};
> Sorry for stepping up so late, but I dont' think this is the right way
> to do it.
> 
Not a issue.

> DT is to describe how the hardware is laid out in a system agnostic
> way, hence, it should not be impacted by the implementation details.
> 
If "hardware is laid out" means at SoC level? Then I attempted to do
describe it in system agnostic way.

On ST SoCs "snps,dwmac" IP always has a hw glue layer on top of it.

> The fact that you use a glue to the dwmac driver *is* an
> implementation detail.

Glue layer described here is actually a hardware glue on ST SoCs.

> 
> I think you'd rather have something like:
> 
> dwmac0: ethernet@fe810000 {
> 	compatible		= "st,stih415-dwmac";
> 	reg 			= <0xfe810000 0x8000 0x148 0x4>;
> 	resets			= <&softreset STIH415_ETH0_SOFTRESET>;
> 	st,syscon		= <&syscfg_rear>;
> 	st,tx-retime-src	= "clk_125";
> 	interrupts 		= <0 147 0>;
> 	interrupt-names 	= "macirq";Am happy to go with 
> 	...
> };
> 
> Then, the driver can have its init functions associated to the
> compatible you're using, through the .data field of the of_device_id
> structure, and you just call it in the generic driver at probe's time.

This is changing the device tree bindings for the generic driver.
Is this something Acceptable?

Peppe, are you Ok with such intrusive changes to the driver?

I did try few things before I sent this patch,

1> Doing it via AUXDATA which was discouraged by Arnd.

2> Doing it the way you suggested which did not fit in very neatly,
which looked like lot of SOC specific changes are added to generic driver.

3> Doing it as this patch, influenced by dwc3 code drivers/usb/dwc3/,
Which fitted in very neatly without touching the existing generic driver.

stmmac driver is a generic synopsis driver which ST has written the
driver, so I did not want to pollute this driver with ST specific glue
logic bindings.

Again, this could be irrelevant/confusing to other people who are using
this driver in there SoCs.

Only thing that bothers me with your suggestion is the changes to
generic driver.


> 
> I don't really know what this syscon thing is either, but I think the
> reg <0x148 0x4> is related to that.
Yes, it is related to that.

> 
> Why don't you pass it directly in the st,syscon property, to have
> something like <&syscfg_rear 0x148>?
This style was once discouraged by Arnd when I first sent pinctrl driver
for reasons that dt should not specify the offsets to registers.

> 
> Maxime

