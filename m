From: kishon <kishon@ti.com>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 16:58:48 +0530
Message-ID: <512361F0.1070500@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com> <201302191044.28653.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <balbi@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <201302191044.28653.arnd@arndb.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 19 February 2013 04:14 PM, Arnd Bergmann wrote:
> On Tuesday 19 February 2013, Kishon Vijay Abraham I wrote:
>> Added a generic PHY framework that provides a set of APIs for the PHY drivers
>> to create/destroy a PHY and APIs for the PHY users to obtain a reference to
>> the PHY with or without using phandle. To obtain a reference to the PHY
>> without using phandle, the platform specfic intialization code (say from board
>> file) should have already called phy_bind with the binding information. The
>> binding information consists of phy's device name, phy user device name and an
>> index. The index is used when the same phy user binds to mulitple phys.
>>
>> This framework will be of use only to devices that uses external PHY (PHY
>> functionality is not embedded within the controller).
>>
>> The intention of creating this framework is to bring the phy drivers spread
>> all over the Linux kernel to drivers/phy to increase code re-use and to
>> increase code maintainability.
>>
>> Comments to make PHY as bus wasn't done because PHY devices can be part of
>> other bus and making a same device attached to multiple bus leads to bad
>> design.
>
> How does this relate to the generic PHY interfaces in drivers/net/phy?

Currently drivers/phy and drivers/net/phy are independent and are not 
related to each other. There are some fundamental differences on how 
these frameworks work. IIUC, the *net* uses bus layer (MDIO bus) to 
match a PHY device with a PHY driver and the Ethernet device uses the 
bus layer to get the PHY.
The Generic PHY Framework however doesn't have any bus layer. The PHY 
should be like any other Platform Devices and Drivers and the framework 
will provide some APIs to register with the framework. And there are 
other APIs which any controller can use to get the PHY (for e.g., in the 
case of dt boot, it can use phandle to get a reference to the PHY).
>
> Do you expect that to get merged into drivers/phy in the long run, or
> do you want to keep the generic phy only for everything but ethernet?

We'd like the PHY drivers spread all over the kernel to get merged to 
drivers/phy including Ethernet. Having said that, Ethernet itself has a 
huge PHY framework and it's going to be little challenging to adapt to 
the new PHY framework (of course there'll be changes in this PHY 
framework when we want to have network PHY added here). But adapting USB 
PHYs to the new framework will be simpler and will be taken first. Also 
when we add SATA PHY (OMAP5), it will make use of this framework as both 
SATA and USB3 uses the same PHY IP.
>
> I think it would be problematic to have two alternative interfaces for
> ethernet PHYs because then an ethernet driver still needs to decide
> which subsystem to interface with.

Right. For now Ethernet should continue to use their own PHY abstraction 
layer till we are a bit more clear on how to move it to drivers/phy.

Thanks
Kishon
