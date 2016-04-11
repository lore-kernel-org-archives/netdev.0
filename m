From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Mon, 11 Apr 2016 17:46:27 -0500
Message-ID: <CAL_Jsq+RYTmRZPLBrXR-Jh66o3A7dpvGhaa451TFr8+=MixM9A@mail.gmail.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3381543.SDQLqND8Pp@wasted.cogentembedded.com> <20160411192521.GA6896@rob-hp-laptop>
 <570BFACF.30507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BFACF.30507@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 2:28 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 04/11/2016 10:25 PM, Rob Herring wrote:
>
>>> The PHY  devices sometimes do have their reset signal (maybe even power
>>> supply?) tied to some GPIO and sometimes it also does happen that a boot
>>> loader does not leave it deasserted. So far this issue has been attacked
>>> from (as I believe) a wrong angle: by teaching the MAC driver to
>>> manipulate
>>> the GPIO in question;  that solution, when  applied to the device trees,
>>> led to adding the PHY reset GPIO properties to the MAC device node, with
>>> one exception: Cadence MACB driver which could handle the "reset-gpios"
>>> prop  in a PHY device  subnode.  I believe that the correct approach is
>>> to
>>> teach the 'phylib' to get the MDIO device reset GPIO from the device tree
>>> node corresponding to this device -- which this patch is doing...
>>>
>>> Note that I had to modify the  AT803x PHY driver as it would stop working
>>> otherwise as it made use of the reset GPIO for its own purposes...
>>
>>
>> Lots of double spaces in here. Please fix.
>
>
>    Oh, it's you again! :-D

Yep, one of those picky kernel maintainers that like a bad rash just
won't go away. :)

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>>   Documentation/devicetree/bindings/net/phy.txt |    2 +
>>>   drivers/net/phy/at803x.c                      |   19 ++------------
>>>   drivers/net/phy/mdio_bus.c                    |    4 +++
>>>   drivers/net/phy/mdio_device.c                 |   27
>>> +++++++++++++++++++--
>>>   drivers/net/phy/phy_device.c                  |   33
>>> ++++++++++++++++++++++++--
>>>   drivers/of/of_mdio.c                          |   16 ++++++++++++
>>>   include/linux/mdio.h                          |    3 ++
>>>   include/linux/phy.h                           |    5 +++
>>>   8 files changed, 89 insertions(+), 20 deletions(-)
>>
>>
>> [...]
>>
>>> Index: net-next/drivers/of/of_mdio.c
>>> ===================================================================
>>> --- net-next.orig/drivers/of/of_mdio.c
>>> +++ net-next/drivers/of/of_mdio.c
>>> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>>>   static int of_mdiobus_register_phy(struct mii_bus *mdio, struct
>>> device_node *child,
>>>                                    u32 addr)
>>>   {
>>> +       struct gpio_desc *gpiod;
>>>         struct phy_device *phy;
>>>         bool is_c45;
>>>         int rc;
>>> @@ -52,10 +53,17 @@ static int of_mdiobus_register_phy(struc
>>>         is_c45 = of_device_is_compatible(child,
>>>                                          "ethernet-phy-ieee802.3-c45");
>>>
>>> +       gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>>
>>
>> Calling fwnode_* functions in a DT specific file/function? That doesn't
>> make sense.
>
>
>    Really?! 8-)
>    Where is a DT-only analog I wonder...

Ah, you're right. NM.

Rob
