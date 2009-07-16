From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro  2.6.31-rc3
Date: Thu, 16 Jul 2009 12:32:50 -0700
Message-ID: <4A5F8062.6090009@candelatech.com>
References: <4A5E5F8A.308@candelatech.com> <Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57036 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbZGPTcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 15:32:51 -0400
In-Reply-To: <Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2009 12:13 PM, Waskiewicz Jr, Peter P wrote:
> On Wed, 15 Jul 2009, Ben Greear wrote:
>
>> I just got a fancy new 10G NIC and tried it out in a (patched elsewhere, but stock ixgbe driver) 2.6.31-rc3) kernel.
>>
>> First of all, it runs very fast:  sustained 9.5Gbps tx + rx on two ports concurrently (using modified pktgen),
>> with 1500 byte pkts.
>>
>> I did see a warning in the boot logs though.
>
> Yes, see below for an explanation.
>
>> ixgbe: 0000:03:00.0: ixgbe_init_interrupt_scheme: Multiqueue Enabled: Rx Queue count = 8, Tx Queue count = 8
>> ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x8) 00:0c:bd:00:90:1a
>> ixgbe 0000:03:00.0: MAC: 2, PHY: 9, SFP+: 5, PBA No: e57138-000
>> ixgbe 0000:03:00.0: This device is a pre-production adapter/LOM.  Please be aware there may be issues associated with your hardware.  If you are experiencing
>> problems please contact your Intel or hardware representative who provided you with this hardware.
>
> It's self-explanatory; the EEPROM version on the NIC is not the
> production-level EEPROM.  If you run ethtool -i ethX on this interface,
> you will see what the firmware (EEPROM) version is.  My guess is it's
> going to be 0.5-1 or something; the production firmware is 0.9-3.  If you
> received this NIC from an Intel rep, they can get you the production
> EEPROM and tools necessary to reprogram the NIC.

Yes, 0.5-1

I got it from interfacemasters.com, but they can probably help me do the same.

> We haven't seen such a panic in our testing, but we don't heavily test
> toggling the LRO flags.  We lightly touch the flags, but nothing heavy.
> Note that there is a difference in this device, 82599 (assumed since
> your lspci shows you're linked at 5.0 Gt/sec), that we have a HW-based
> LRO running.  This is the preferred configuration the driver uses at
> load; there may be something broken with how we switch between HW LRO +
> GRO and just straight GRO.

I believe the trigger for this is my script that enables ip_forward.  I'm
not twiddling LRO settings directly as far as I can tell.

> I will see if our validation guys can reproduce this.  In the meantime,
> can you try without preempt enabled?  Also, it wasn't obvious to me if
> this is 100% reproducible, or if it's racy.  Can you comment on that?

It is 100% reproducible on the system I'm testing.  I haven't tried other servers
or other ixgbe NICs yet.

I'll try w/out pre-empt, should have results later today.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

