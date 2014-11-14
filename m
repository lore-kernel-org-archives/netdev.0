From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Fri, 14 Nov 2014 08:39:43 +0100
Message-ID: <CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
	<54650E9C.7080708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43701 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbaKNHjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 02:39:48 -0500
Received: by mail-ie0-f182.google.com with SMTP id rd18so17663497iec.13
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 23:39:47 -0800 (PST)
In-Reply-To: <54650E9C.7080708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 9:03 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/13/2014 07:15 AM, Oliver Graute wrote:
>> Hello Florian,
>>
>> On Wed, Nov 12, 2014 at 8:19 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 11/12/2014 05:07 AM, Oliver Graute wrote:
>>>> Hello,
>>>>
>>>> how do I specify the DSA node and the MDIO node in the Device Tree
>>>> Binding to integrate a Marvell 88e6071 switch with a imx28 board?
>>>>
>>>> On my board the Marvell switch 88e6071 is connected via phy1 (on a
>>>> imx28 PCB) to phy5 on the Marvell switch (on a Switch PCB). All phys
>>>> are connected via the same MDIO Bus.
>>>>
>>>> I enabled the Marvell DSA Support Driver, Gianfar Ethernet Driver and
>>>> Freescale PQ MDIO Driver in the Kernel (I' am not sure if this is the
>>>> right choice for imx28 fec ethernet controller is it?)
>>>>
>>
>> I changed my DeviceTree according to your proposal. Now I got a ENODEV 19
>> in dsa_of_probe. Because  of_find_device_by_node(ethernet) is returning 0.
>> Is my ethernet setting still wrong?
>
> Is your ethernet driver also modular? If so, you will need it to be
> loaded *before* dsa. of_find_device_by_node() also needs the ethernet
> driver to be a platform_driver.

No my Freescale FEC PHY driver is not a module. FEC is a imx28/arm
platform driver or not?

I loaded the DSA as a Kernel module to make sure that the DSA probing
is happening when the switch is really on. I enable the SWITCH ON Pin
on bootup with a systemd started script. Then I write some registers
on the switch with a userspace mii tool. This manually writing of some
switch registers works fine via the MII Bus using ioctl(SIOCGMIIPHY).

But i would like to integrate the switch with a full dsa driver.
currently its failing with dsa_of_probe returns=-19

> NB: I have a patch that looks up a net_device based on the struct
> device_node that might be better to use, since it makes no assumption
> about whether that is a platform_device/pci_device etc...

can you give me a link to this patch?

Best Regards,

Oliver
