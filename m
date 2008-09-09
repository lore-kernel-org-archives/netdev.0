From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Channel bonding with e1000
Date: Tue, 09 Sep 2008 08:21:08 +0200
Message-ID: <48C615D4.30409@aei.mpg.de>
References: <48C0EF8A.9070103@aei.mpg.de> <alpine.WNT.1.10.0809081133290.7512@jbrandeb-MOBL1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:55502 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbYIIGVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 02:21:13 -0400
In-Reply-To: <alpine.WNT.1.10.0809081133290.7512@jbrandeb-MOBL1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

Brandeburg, Jesse wrote:
>> 05:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
>> Controller (rev 03)
>> 05:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
>> Controller (rev 03)
> 
> This chip is connected over PCI-X and should be significantly slower 
> and/or higher CPU utilization than the ESB2 based chip.

At first I couldn't believe it since I put in some of the cards myself
and those were PCIe x1 cards. But checking with lshw it looks you are
right (and the expert anyway):

  *-pci:1
                description: PCI bridge
                product: 6311ESB/6321ESB PCI Express to PCI-X Bridge
                vendor: Intel Corporation
                physical id: 0.3
                bus info: pci@01:00.3
                version: 01
                width: 32 bits
                clock: 33MHz
                capabilities: pci normal_decode bus_master cap_list
              *-network:0 DISABLED
                   description: Ethernet interface
                   product: 82546GB Gigabit Ethernet Controller
                   vendor: Intel Corporation
                   physical id: 2
                   bus info: pci@05:02.0
                   logical name: eth2
                   version: 03
                   serial: 00:1b:21:0d:c4:2c
                   capacity: 1GB/s
                   width: 64 bits
                   clock: 66MHz
                   capabilities: bus_master cap_list ethernet physical
tp 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd autonegotiation
                   configuration: autonegotiation=on broadcast=yes
driver=e1000 driverversion=7.3.20-k2-NAPI firmware=N/A latency=52
link=no mingnt=255 multicast=yes port=twisted pair
                   resources: iomemory:d8080000-d809ffff
iomemory:d8000000-d803ffff ioport:3000-303f irq:28
              *-network:1
                   description: Ethernet interface
                   product: 82546GB Gigabit Ethernet Controller
                   vendor: Intel Corporation
                   physical id: 2.1
                   bus info: pci@05:02.1
                   logical name: eth3
                   version: 03
                   serial: 00:1b:21:0d:c4:2d
                   size: 100MB/s
                   capacity: 1GB/s
                   width: 64 bits
                   clock: 66MHz
                   capabilities: bus_master cap_list ethernet physical
tp 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd autonegotiation
                   configuration: autonegotiation=on broadcast=yes
driver=e1000 driverversion=7.3.20-k2-NAPI duplex=full firmware=N/A
ip=172.28.11.4 latency=52 link=yes mingnt=255 multicast=yes port=twisted pai
r speed=100MB/s
                   resources: iomemory:d80a0000-d80bffff
iomemory:d8040000-d807ffff ioport:3040-307f irq:29

> 
> It shouldn't matter, but I would take into consideration that the ESB2 
> ports should be faster.
> 

We'll start looking into this soon and try to get some tests underway.

> 
> PS in the future questions like this could be cc:'d to 
> e1000-devel@lists.sourceforge.net where all the Intel wired developers 
> hang out (in addition to netdev)

Sorry, I should have remembered that one from ~6-9 months ago. Sorry,
I'll start with that mid-thread (and another sorry for that).

Cheers

Carsten
