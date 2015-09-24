From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 15:14:51 -0700 (PDT)
Message-ID: <20150924.151451.1059470233561232912.davem@davemloft.net>
References: <1442968896-30776-1-git-send-email-ddaney.cavm@gmail.com>
	<20150924.145206.897667718297700953.davem@davemloft.net>
	<56047367.3060101@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, david.daney@cavium.com
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56047367.3060101@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 24 Sep 2015 15:04:23 -0700

> On 09/24/2015 02:52 PM, David Miller wrote:
>> From: David Daney <ddaney.cavm@gmail.com>
>> Date: Tue, 22 Sep 2015 17:41:36 -0700
>>
>>> From: David Daney <david.daney@cavium.com>
>>>
>>> When the Cavium mdio-octeon devices appear in the Thunder family of
>>> arm64 based SoCs, they show up as PCI devices.  Add PCI driver
>>> wrapping so the driver is bound in the standard PCI device scan.
>>>
>>> When in this form, a single PCI device may have more than a single
>>> bus, we call this a "nexus" of buses.  The standard firmware
>>> device_for_each_child_node() iterator is used to find the individual
>>> buses underneath the "nexus".
>>>
>>> Update the device tree binding documentation for the new PCI driver
>>> binding.
>>>
>>> Signed-off-by: David Daney <david.daney@cavium.com>
>>
>> This patch breaks the build:
> 
> For which architecture?
> 
> I tested it on mips and arm64.  I will try x86, as I guess that is
> where you tried your test build.

x86-64.

> There is, somewhat of, a method behind the madness here.
> 
> In order to use MSI-X interrupts, we need a corresponding PCI
> device. Now, this driver doesn't currently use interrupts, but other
> devices in the SoC do, so they must be PCI devices.

"I need this thing, which isn't needed, therefore I'm making this
change."

Sorry, that's not a good argument.

ACPI nodes have names and whatnot as well.

So I haven't heard a compelling argument so far.

So why not just implement this cleanly and using the existing
framework now, and then when you have a legitimate reason for making a
major change to the probing scheme you can do it then.
