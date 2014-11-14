From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Fri, 14 Nov 2014 15:52:03 +0100
Message-ID: <CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
	<54650E9C.7080708@gmail.com>
	<CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:40985 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964875AbaKNOwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 09:52:04 -0500
Received: by mail-ig0-f177.google.com with SMTP id uq10so350892igb.4
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 06:52:03 -0800 (PST)
In-Reply-To: <CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 8:39 AM, Oliver Graute <oliver.graute@gmail.com> wrote:
> On Thu, Nov 13, 2014 at 9:03 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 11/13/2014 07:15 AM, Oliver Graute wrote:
>>> Hello Florian,
>>>
>>> On Wed, Nov 12, 2014 at 8:19 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> On 11/12/2014 05:07 AM, Oliver Graute wrote:
>>>>> Hello,
>>>>>
>>>>> how do I specify the DSA node and the MDIO node in the Device Tree
>>>>> Binding to integrate a Marvell 88e6071 switch with a imx28 board?
>>>>>
>>>>> On my board the Marvell switch 88e6071 is connected via phy1 (on a
>>>>> imx28 PCB) to phy5 on the Marvell switch (on a Switch PCB). All phys
>>>>> are connected via the same MDIO Bus.
>>>>>
>>>>> I enabled the Marvell DSA Support Driver, Gianfar Ethernet Driver and
>>>>> Freescale PQ MDIO Driver in the Kernel (I' am not sure if this is the
>>>>> right choice for imx28 fec ethernet controller is it?)
>>>>>
>>>
>>> I changed my DeviceTree according to your proposal. Now I got a ENODEV 19
>>> in dsa_of_probe. Because  of_find_device_by_node(ethernet) is returning 0.
>>> Is my ethernet setting still wrong?
>>
>> Is your ethernet driver also modular? If so, you will need it to be
>> loaded *before* dsa. of_find_device_by_node() also needs the ethernet
>> driver to be a platform_driver.
>
> No my Freescale FEC PHY driver is not a module. FEC is a imx28/arm
> platform driver or not?
>
> I loaded the DSA as a Kernel module to make sure that the DSA probing
> is happening when the switch is really on. I enable the SWITCH ON Pin
> on bootup with a systemd started script. Then I write some registers
> on the switch with a userspace mii tool. This manually writing of some
> switch registers works fine via the MII Bus using ioctl(SIOCGMIIPHY).
>
> But i would like to integrate the switch with a full dsa driver.
> currently its failing with dsa_of_probe returns=-19
>

the dsa_core driver is probing the mii_bus before eth0 and eth1 are
detected via the FEC Driver.

[   20.716253] !!!!!enter dsa_init_module!!!!!
[   20.777046] !!!!Enter dsa Probe!!!!!
[   20.803422] Distributed Switch Architecture driver version 0.1
[   20.809295] !!!!!Enter dsa_of_probe!!!!!
[   20.888268] !!!!!mdio->name=mdio mdio->type=mdio
mdio->full_name=/mdio@800f0040 !!!!!
[   20.999618] !!!!!np->name=dsa np->type=<NULL> np->full_name=/dsa@0 !!!!!
[   21.097805] !!!!before of_mdio_find_bus!!!!!
[   21.137278] !!!!!enter of_mdio_find_bus!!!!!
[   21.190232] !!!!!enter of_mdio_bus_match!!!!!
[   21.194635] !!!!!enter of_mdio_bus_match!!!!!
[   21.199000] !!!!!enter of_mdio_bus_match!!!!!
[   21.300627] !!!!Leave of_mdio_find_bus !!!!!
[   21.304949] !!!!after of_mdio_find_bus mdio_bus=Freescale
PowerQUICC MII Bus !!!!!
[   21.456904] !!!!before of_parse_phandle dsa,ethernet!!!!!
[   21.570569] !!!!before of find_device_by_node!!!!!
[   21.575416] !!!!!ethernet->name=ethernet ethernet->type=<NULL>
ethernet->full_name=/ahb@80080000/ethernet@800f4000 !!!!!
[   21.860234] !!!!! enter of_find_device_by_node !!!!!
[   21.865284] !!!!! Leave of_find_device_by_node dev=c790fe10 !!!!!
[   21.970600] !!!!! dev->init_name=(null) !!!!!
[   21.975001] before to_platform_device test->name=800f4000.ethernet
[   22.088915] !!!!before of kzalloc!!!!!
[   22.134753] !!!!before pd->netdev!!!!!
[   22.138548] !!!!before dev_to_net_device!!!!!
[   22.210241] !!!!dev_put(dev)!!!!!
[   22.213600] !!!!kzalloc!!!!!
[   22.216493] !!!!platform_set_drv_data!!!!!
[   22.313247] !!!!!enter dev_to_mii_bus!!!!!
[   22.317393] !!!!!enter dsa_switch_setup!!!!!
[   22.394756] !!!!name=!!!!!
[   22.397691] !!!!bus->name=Freescale PowerQUICC MII Bus!!!!!
[   22.502050] !!!!pd->sw_addr=3!!!!!
[   22.505489] !!!!Enter dsa_switch_probe!!!!!
[   22.509685] !!!!Leave dsa_switch_probe!!!!!
[   22.630239] eth1[0]: could not detect attached switch
[   22.635337] eth1[0]: couldn't create dsa switch instance (error -22)
[   22.740538] !!!!Leave dsa Probe!!!!!
[   22.794305] !!!!!leave dsa_init_module!!!!!

[   65.954070] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Micrel KSZ8041] (mii_bus:phy_addr=800f0000.etherne:00, irq=-1)
[   66.067135] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   66.532877] fec 800f4000.ethernet eth1: Freescale FEC PHY driver
[Micrel KSZ8041] (mii_bus:phy_addr=800f0000.etherne:01, irq=-1)

if i manually rmmod and modprobe the dsa_core driver  after FEC PHY
detection again i got a  EEXIST 17

modprobe dsa_core
[  212.770578] !!!!!enter dsa_init_module!!!!!
[  212.775121] !!!!Enter dsa Probe!!!!!
[  212.778726] Distributed Switch Architecture driver version 0.1
[  212.791071] !!!!!Enter dsa_of_probe!!!!!
[  212.795191] !!!!!mdio->name=mdio mdio->type=mdio
mdio->full_name=/mdio@800f0040 !!!!!
[  212.805452] !!!!!np->name=dsa np->type=<NULL> np->full_name=/dsa@0 !!!!!
[  212.813355] !!!!before of_mdio_find_bus!!!!!
[  212.817669] !!!!!enter of_mdio_find_bus!!!!!
[  212.823707] !!!!!enter of_mdio_bus_match!!!!!
[  212.828111] !!!!!enter of_mdio_bus_match!!!!!
[  212.834213] !!!!!enter of_mdio_bus_match!!!!!
[  212.838620] !!!!Leave of_mdio_find_bus !!!!!
[  212.844655] !!!!after of_mdio_find_bus mdio_bus=Freescale
PowerQUICC MII Bus !!!!!
[  212.853684] !!!!before of_parse_phandle dsa,ethernet!!!!!
[  212.859179] !!!!before of find_device_by_node!!!!!
[  212.866019] !!!!!ethernet->name=ethernet ethernet->type=<NULL>
ethernet->full_name=/ahb@80080000/ethernet@800f4000 !!!!!
[  212.878029] !!!!! enter of_find_device_by_node !!!!!
[  212.884159] !!!!! Leave of_find_device_by_node dev=c790fe10 !!!!!
[  212.891366] !!!!! dev->init_name=(null) !!!!!
[  212.895769]
[  212.895769] before to_platform_device test->name=800f4000.ethernet
[  212.905738] !!!!before of kzalloc!!!!!
[  212.909586] !!!!before pd->netdev!!!!!
[  212.915402] !!!!before dev_to_net_device!!!!!
[  212.919817] !!!!dev_put(dev)!!!!!
[  212.925431] dsa: probe of dsa.5 failed with error -17
[  212.936922] !!!!!leave dsa_init_module!!!!!


best regards,

Oliver
