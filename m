From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Question on Bonding driver
Date: Fri, 20 Feb 2015 11:59:44 -0500
Message-ID: <54E76800.4050604@ti.com>
References: <54DE3056.6020606@ti.com> <4331.1423931133@nyx>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:48254 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886AbbBTQ7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 11:59:46 -0500
In-Reply-To: <4331.1423931133@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2015 11:25 AM, Jay Vosburgh wrote:
> Murali Karicheri<m-karicheri2@ti.com>  wrote:
>
>> Hi,
>>
>> I am working to enable bonding driver on my hardware and trying to
>> understand this.
>>
>> I am using the alb mode. I create a bond interface with 2 ethernet
>> interfaces. First one is the basic question about net driver itself and
>> second is about bonding.
>>
>> 1. Each ethernet interface has a MAC address. The hardware has MAC filter
>> and the driver fills the net_device's dev_addr with its MAC address before
>> calling register_netdev() API. When the net core calls ndo_start(), is the
>> low level driver responsible for setting up its MAC address in the MAC
>> filter of the hardware or low level driver will be told to do so by upper
>> layer. Or is it required to set it up as part of ndo_set_rx_mode() or
>> ndo_set_mac_address()?
>>
>> 2. In the case of bonding, the bond interface MAC address is copied from
>> the active slave's MAC address. Also it updates the dev_addr in the netdev
>> struct of each of the slave with its own MAC address. So I assume, the
>> device/NIC now needs to accept packets to its original MAC address as well
>> the bond's MAC address. This is especially more important for the slave's
>> that are not active slave as it can be target of packets from Peers as
>> part of rlb. So for the slave that is not active slave, MAC filter needs
>> to include its original hw address as well unless the slave is put to
>> promiscuous mode. So I am trying to figure out how this is expected to
>> work? All slaves put to promiscuous mode or MAC filter updated by slave
>> driver to include MAC addresses it is expected to filter on (bond MAC
>> address and its own MAC address)
>
> 	I'm travelling at the moment, but the short answer for #2 is
> that the way the alb mode works is basically that the non-active slaves
> only receive for their own individual MAC.  Peers within the L2 network
> are "assigned" to those slaves via tailored ARPs sent to the specific
> peers.  The slaves do not generally go into promisc mode (there are
> exceptions during failover type events), nor are they programmed with
> multiple unicast MAC addreeses.
>
> 	I'd suggest you look at rlb_update_client in bond_alb.c and the
> functions that call it to understand the logic.

Thanks Jay. Will take a look.

Murali
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
>
>


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
