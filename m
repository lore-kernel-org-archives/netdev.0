From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 15:45:41 -0700
Message-ID: <56047D15.9080105@caviumnetworks.com>
References: <1442968896-30776-1-git-send-email-ddaney.cavm@gmail.com> <20150924.145206.897667718297700953.davem@davemloft.net> <56047367.3060101@caviumnetworks.com> <20150924.151451.1059470233561232912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150924.151451.1059470233561232912.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/24/2015 03:14 PM, David Miller wrote:
> From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
> Date: Thu, 24 Sep 2015 15:04:23 -0700
>
>> On 09/24/2015 02:52 PM, David Miller wrote:
>>> From: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Date: Tue, 22 Sep 2015 17:41:36 -0700
>>>
>>>> From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>>>
>>>> When the Cavium mdio-octeon devices appear in the Thunder family of
>>>> arm64 based SoCs, they show up as PCI devices.  Add PCI driver
>>>> wrapping so the driver is bound in the standard PCI device scan.
>>>>
>>>> When in this form, a single PCI device may have more than a single
>>>> bus, we call this a "nexus" of buses.  The standard firmware
>>>> device_for_each_child_node() iterator is used to find the individual
>>>> buses underneath the "nexus".
>>>>
>>>> Update the device tree binding documentation for the new PCI driver
>>>> binding.
>>>>
>>>> Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>>
>>> This patch breaks the build:
>>
>> For which architecture?
>>
>> I tested it on mips and arm64.  I will try x86, as I guess that is
>> where you tried your test build.
>
> x86-64.
>
>> There is, somewhat of, a method behind the madness here.
>>
>> In order to use MSI-X interrupts, we need a corresponding PCI
>> device. Now, this driver doesn't currently use interrupts, but other
>> devices in the SoC do, so they must be PCI devices.
>
> "I need this thing, which isn't needed, therefore I'm making this
> change."
>

That is not the exact argument.  It is really more like this:

1) The firmware is supplying a uniform view of the devices by making 
them all PCI devices.  This is done because:

    a) Devices that use interrupts must be PCI.

    b) Uniformity is good.

2) The OF device tree nodes for PCI devices do not result in the 
creation of a platform device.

3) If there is no platform device, platform device driver binding does 
not occur, and the device is useless to the kernel.

So, we think it is a good change.  I don't really want to argue about 
the  semantics of it being a "needed change".

> Sorry, that's not a good argument.
>
> ACPI nodes have names and whatnot as well.
>
> So I haven't heard a compelling argument so far.
>
> So why not just implement this cleanly and using the existing
> framework now, and then when you have a legitimate reason for making a
> major change to the probing scheme you can do it then.
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
