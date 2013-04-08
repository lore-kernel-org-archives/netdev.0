From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Mon, 8 Apr 2013 18:51:15 +0530
Message-ID: <5162C44B.90501@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com> <1364993634-6378-2-git-send-email-kishon@ti.com> <515CC123.4060402@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <balbi@ti.com>, <gregkh@linuxfoundation.org>, <arnd@arndb.de>,
	<akpm@linux-foundation.org>, <sylvester.nawrocki@gmail.com>,
	<rob@landley.net>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<cesarb@cesarb.net>, <linux-usb@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tony@atomide.com>, <grant.likely@secretlab.ca>,
	<rob.herring@calxeda.com>, <b-cousson@ti.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <mchehab@redhat.com>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <515CC123.4060402@wwwdotorg.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thursday 04 April 2013 05:24 AM, Stephen Warren wrote:
> On 04/03/2013 06:53 AM, Kishon Vijay Abraham I wrote:
>> The PHY framework provides a set of APIs for the PHY drivers to
>> create/destroy a PHY and APIs for the PHY users to obtain a reference to the
>> PHY with or without using phandle. To obtain a reference to the PHY without
>> using phandle, the platform specfic intialization code (say from board file)
>> should have already called phy_bind with the binding information. The binding
>> information consists of phy's device name, phy user device name and an index.
>> The index is used when the same phy user binds to mulitple phys.
>>
>> PHY drivers should create the PHY by passing phy_descriptor that has
>> describes the PHY (label, type etc..) and ops like init, exit, suspend, resume,
>> power_on, power_off.
>>
>> The documentation for the generic PHY framework is added in
>> Documentation/phy.txt and the documentation for the sysfs entry is added
>> in Documentation/ABI/testing/sysfs-class-phy and the documentation for
>> dt binding is can be found at
>> Documentation/devicetree/bindings/phy/phy-bindings.txt
>
>> diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
>
>> +extern struct phy *devm_phy_create(struct device *dev, const char *label,
>> +	struct device_node *of_node, int type, struct phy_ops *ops,
>> +	void *priv);
>
> Can't the function get of_node from dev->of_node?
>
> I wonder if we shouldn't split up the registration a bit though:
>
> A function which registers a PHY object itself. That's the function above.
>
> A function which registers a DT-based PHY provider.
>
> Then, the of_xlate op would be part of the PHY provider, not part of
> some random PHY that happens to exist on that node. So:

Yeah. Makes sense to me. By this we can avoid struct phy * to represent 
two different things (phy provider and phy instance).

Thanks
Kishon
