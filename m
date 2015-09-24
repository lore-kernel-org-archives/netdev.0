From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 15:04:23 -0700
Message-ID: <56047367.3060101@caviumnetworks.com>
References: <1442968896-30776-1-git-send-email-ddaney.cavm@gmail.com> <20150924.145206.897667718297700953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ddaney.cavm@gmail.com>, <linux-kernel@vger.kernel.org>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <david.daney@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150924.145206.897667718297700953.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2015 02:52 PM, David Miller wrote:
> From: David Daney <ddaney.cavm@gmail.com>
> Date: Tue, 22 Sep 2015 17:41:36 -0700
>
>> From: David Daney <david.daney@cavium.com>
>>
>> When the Cavium mdio-octeon devices appear in the Thunder family of
>> arm64 based SoCs, they show up as PCI devices.  Add PCI driver
>> wrapping so the driver is bound in the standard PCI device scan.
>>
>> When in this form, a single PCI device may have more than a single
>> bus, we call this a "nexus" of buses.  The standard firmware
>> device_for_each_child_node() iterator is used to find the individual
>> buses underneath the "nexus".
>>
>> Update the device tree binding documentation for the new PCI driver
>> binding.
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>
> This patch breaks the build:

=46or which architecture?

I tested it on mips and arm64.  I will try x86, as I guess that is wher=
e=20
you tried your test build.


>
>    CC [M]  drivers/net/phy/mdio-octeon.o
> In file included from drivers/net/phy/mdio-octeon.c:13:0:
> include/linux/module.h:128:27: error: redefinition of =A1__inittest=A2
>    static inline initcall_t __inittest(void)  \
>                             ^
[...]

>
> And frankly I'm not sure I like this change anyways.  If the OF nodes
> are there, simply add code to match on those OF nodes.
>
> This is better than assuming what sits underneath a PCI node, without
> any checks for the 'name' or 'compatible' properties at all.  That's
> what they are there for afterall.

There is, somewhat of, a method behind the madness here.

In order to use MSI-X interrupts, we need a corresponding PCI device.=20
Now, this driver doesn't currently use interrupts, but other devices in=
=20
the SoC do, so they must be PCI devices.

The idea is to have the type of all drivers uniformly be PCI, rather=20
than a random mix of PCI and platform, and then switch them back and=20
forth as PCI features are/are-not used in the driver.

Also we need to consider ACPI firmware in addition to OF device tree.

David Daney
