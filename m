From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v3)
Date: Tue, 11 Nov 2008 11:03:52 +0200
Message-ID: <49194A78.8040202@teltonika.lt>
References: <20081110151145.12986.45668.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <200811101815.54126.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <200811101815.54126.laurentp@cse-semaphore.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Pinchart wrote:
> Hi Paulius,
> 
> sorry for the late reply. I've been busy at work with a release and had no 
> time to test the patch. Comments follow.
> 
> On Monday 10 November 2008, Paulius Zaleckas wrote:
>> make mdio-gpio work with non OpenFirmware gpio implementation.
>>
>> Aditional changes to mdio-gpio:
>> - use gpio_request() and gpio_free()
>> - place irq[] array in struct mdio_gpio_info
>> - add module description, author and license
>> - add note about compiling this driver as module
>> - rename mdc and mdio function (were ugly names)
>> - change MII to MDIO in bus name
>> - add __init __exit to module (un)loading functions
>> - probe fails if no phys added to the bus
>> - kzalloc bitbang with sizeof(*bitbang)
>>
>> Changes since v2:
>> - more #ifdefs reduction
>> - platform driver will be registered on OF platforms also
>> - unified platform and OF bus_id to phy%i
>>
>> Changes since v1:
>> - removed NO_IRQ
>> - reduced #idefs
>>
>> Laurent, please test this driver under OF.
> 
> Unfortunately this breaks on OF platforms (at least on mine):
> 
> ~ # ifconfig eth0 up
> [  258.886051] eb:01 not found
> [  258.887409] eth0: Could not attach to phy
> 
> The bus id was "%x"...
>
> And you renamed it to phy%i. Ethernet drivers relying on the id should be 
> updated as well.

I done this to be closer to what phylib documentation says...
I did search over drivers and found out that almost all of them uses "%x"...

> Updating drivers/net/fs_enet/fs_enet-main.c (in find_phy) fixed the problem 
> for my platform. Please not that this requires a change to 
> drivers/net/fs_enet/mii-bitbang.c (in fs_mii_bitbang_init) as well.

A lot more than that...
So actually it is better to just change it back to "%x".

Waiting for comments from other people and I will respin patch with this change.
