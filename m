From: Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Mon, 10 Feb 2014 11:30:30 +0100
Message-ID: <CAH9NwWfutp6MitSuG-LNH=0Y0ffewuSawLXJOe2JUL7=tz7BWQ@mail.gmail.com>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130911064248.GI30088@pengutronix.de> <CAH9NwWfBGHmZ+HfUndeh18NW+HyZ=c82W=O_4hJSOH-oZuM9jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAH9NwWfBGHmZ+HfUndeh18NW+HyZ=c82W=O_4hJSOH-oZuM9jA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2013-09-25 9:12 GMT+02:00 Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> Hi
>
>>> Hello,
>>>
>>> Here is a second version of the patch set that adds a Device Tree
>>> binding and the related code to support fixed PHYs. Marked as RFC,
>>> this patch set is obviously not intended for merging in 3.12.
>>>
>>> Since the first version, the changes have been:
>>>
>>>  * Instead of using a 'fixed-link' property inside the Ethernet device
>>>    DT node, with a fairly cryptic succession of integer values, we now
>>>    use a PHY subnode under the Ethernet device DT node, with explicit
>>>    properties to configure the duplex, speed, pause and other PHY
>>>    properties.
>>>
>>>  * The PHY address is automatically allocated by the kernel and no
>>>    longer visible in the Device Tree binding.
>>>
>>>  * The PHY device is created directly when the network driver calls
>>>    of_phy_connect_fixed_link(), and associated to the PHY DT node,
>>>    which allows the existing of_phy_connect() function to work,
>>>    without the need to use the deprecated of_phy_connect_fixed_link().
>>>
>>> The things I am not entirely happy with yet are:
>>>
>>>  * The PHY ID is hardcoded to 0xdeadbeef. Ideally, it should be a
>>>    properly reserved vendor/device identifier, but it isn't clear how
>>>    to get one allocated for this purpose.
>>>
>>>  * The fixed_phy_register() function in drivers/net/phy/fixed.c has
>>>    some OF references. So ideally, I would have preferred to put this
>>>    code in drivers/of/of_mdio.c, but to call get_phy_device(), we need
>>>    a reference to the mii_bus structure that represents the fixed MDIO
>>>    bus.
>>>
>>>  * There is some error management missing in fixed_phy_register(), but
>>>    it can certainly be added easily. This RFC is meant to sort out the
>>>    general idea.
>>
>> +1 for the general idea. This really looks good now. I've not much more
>> to say. Maybe someone from the devicetree corner has a few words for the
>> binding?
>>
>
> I tested the whole series with an I.MX6D board with the FEC driver:
> fec 2188000.ethernet eth0: Freescale FEC PHY driver [Generic PHY]
> (mii_bus:phy_addr=fixed-0:00, irq=-1)
>
> For me binding looks nice and I hope to see this patch series in 3.13.
>
> Tested-by: Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Is there any update on this patch series?

--
Christian Gmeiner, MSc

https://soundcloud.com/christian-gmeiner
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
