From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Mon, 11 Apr 2016 22:28:15 +0300
Message-ID: <570BFACF.30507@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3381543.SDQLqND8Pp@wasted.cogentembedded.com>
 <20160411192521.GA6896@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160411192521.GA6896@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2016 10:25 PM, Rob Herring wrote:

>> The PHY  devices sometimes do have their reset signal (maybe even power
>> supply?) tied to some GPIO and sometimes it also does happen that a boot
>> loader does not leave it deasserted. So far this issue has been attacked
>> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
>> the GPIO in question;  that solution, when  applied to the device trees,
>> led to adding the PHY reset GPIO properties to the MAC device node, with
>> one exception: Cadence MACB driver which could handle the "reset-gpios"
>> prop  in a PHY device  subnode.  I believe that the correct approach is to
>> teach the 'phylib' to get the MDIO device reset GPIO from the device tree
>> node corresponding to this device -- which this patch is doing...
>>
>> Note that I had to modify the  AT803x PHY driver as it would stop working
>> otherwise as it made use of the reset GPIO for its own purposes...
>
> Lots of double spaces in here. Please fix.

    Oh, it's you again! :-D

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>>
>> ---
>>   Documentation/devicetree/bindings/net/phy.txt |    2 +
>>   drivers/net/phy/at803x.c                      |   19 ++------------
>>   drivers/net/phy/mdio_bus.c                    |    4 +++
>>   drivers/net/phy/mdio_device.c                 |   27 +++++++++++++++++++--
>>   drivers/net/phy/phy_device.c                  |   33 ++++++++++++++++++++++++--
>>   drivers/of/of_mdio.c                          |   16 ++++++++++++
>>   include/linux/mdio.h                          |    3 ++
>>   include/linux/phy.h                           |    5 +++
>>   8 files changed, 89 insertions(+), 20 deletions(-)
>
> [...]
>
>> Index: net-next/drivers/of/of_mdio.c
>> ===================================================================
>> --- net-next.orig/drivers/of/of_mdio.c
>> +++ net-next/drivers/of/of_mdio.c
>> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>>   static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
>>   				   u32 addr)
>>   {
>> +	struct gpio_desc *gpiod;
>>   	struct phy_device *phy;
>>   	bool is_c45;
>>   	int rc;
>> @@ -52,10 +53,17 @@ static int of_mdiobus_register_phy(struc
>>   	is_c45 = of_device_is_compatible(child,
>>   					 "ethernet-phy-ieee802.3-c45");
>>
>> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>
> Calling fwnode_* functions in a DT specific file/function? That doesn't
> make sense.

    Really?! 8-)
    Where is a DT-only analog I wonder...

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
