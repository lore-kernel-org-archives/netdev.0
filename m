From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 15:12:03 -0700
Message-ID: <56047533.4020906@caviumnetworks.com>
References: <1442968896-30776-1-git-send-email-ddaney.cavm@gmail.com> <20150924.145206.897667718297700953.davem@davemloft.net> <56047367.3060101@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56047367.3060101-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/24/2015 03:04 PM, David Daney wrote:
> On 09/24/2015 02:52 PM, David Miller wrote:
>> From: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Tue, 22 Sep 2015 17:41:36 -0700
>>
>>> From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>>
>>> When the Cavium mdio-octeon devices appear in the Thunder family of
>>> arm64 based SoCs, they show up as PCI devices.  Add PCI driver
>>> wrapping so the driver is bound in the standard PCI device scan.
>>>
>>> When in this form, a single PCI device may have more than a single
>>> bus, we call this a "nexus" of buses.  The standard firmware
>>> device_for_each_child_node() iterator is used to find the individua=
l
>>> buses underneath the "nexus".
>>>
>>> Update the device tree binding documentation for the new PCI driver
>>> binding.
>>>
>>> Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>
>> This patch breaks the build:
>
> For which architecture?
>
> I tested it on mips and arm64.  I will try x86, as I guess that is wh=
ere
> you tried your test build.
>
>
>>
>>    CC [M]  drivers/net/phy/mdio-octeon.o
>> In file included from drivers/net/phy/mdio-octeon.c:13:0:
>> include/linux/module.h:128:27: error: redefinition of =A1__inittest=A2
>>    static inline initcall_t __inittest(void)  \
>>

OK, I reproduced this failure.  It happens with a module build only.

Sorry for the breakage, I will fix it and resubmit.

David Daney


                              ^
> [...]
>
>>
>> And frankly I'm not sure I like this change anyways.  If the OF node=
s
>> are there, simply add code to match on those OF nodes.
>>
>> This is better than assuming what sits underneath a PCI node, withou=
t
>> any checks for the 'name' or 'compatible' properties at all.  That's
>> what they are there for afterall.
>
> There is, somewhat of, a method behind the madness here.
>
> In order to use MSI-X interrupts, we need a corresponding PCI device.
> Now, this driver doesn't currently use interrupts, but other devices =
in
> the SoC do, so they must be PCI devices.
>
> The idea is to have the type of all drivers uniformly be PCI, rather
> than a random mix of PCI and platform, and then switch them back and
> forth as PCI features are/are-not used in the driver.
>
> Also we need to consider ACPI firmware in addition to OF device tree.
>
> David Daney
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
