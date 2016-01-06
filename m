From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Wed, 6 Jan 2016 11:05:18 +0800
Message-ID: <568C846E.6020304@gmail.com>
References: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
 <1586.1450389436@famine> <20151228084331.GA22747@unicorn.suse.cz>
 <5680FE85.60200@gmail.com>
 <87618083B2453E4A8714035B62D6799250503CE1@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35906 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcAFDF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 22:05:27 -0500
Received: by mail-pf0-f173.google.com with SMTP id 65so185598476pff.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 19:05:26 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D6799250503CE1@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2016 09:26 AM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of zhuyj
>> Sent: Monday, December 28, 2015 1:19 AM
>> To: Michal Kubecek; Jay Vosburgh
>> Cc: vfalico@gmail.com; gospo@cumulusnetworks.com; netdev@vger.kernel.org;
>> Shteinbock, Boris (Wind River)
>> Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>>
>> On 12/28/2015 04:43 PM, Michal Kubecek wrote:
>>> On Thu, Dec 17, 2015 at 01:57:16PM -0800, Jay Vosburgh wrote:
>>>> <zyjzyj2000@gmail.com> wrote:
>>>>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>>>> there is a time span between NIC up state and getting speed and duplex.
>>>>> As such, sometimes a slave in 802.3ad mode is in up state without
>>>>> speed and duplex. This will make bonding in 802.3ad mode can not
>>>>> work well.
>>>>> To make bonding driver be compatible with more NICs, it is
>>>>> necessary to restrict the up state in 802.3ad mode.
>>>> 	What device is this?  It seems a bit odd that an Ethernet device
>>>> can be carrier up but not have the duplex and speed available.
>>> ...
>>>> 	In general, though, bonding expects a speed or duplex change to
>>>> be announced via a NETDEV_UPDATE or NETDEV_UP notifier, which would
>>>> propagate to the 802.3ad logic.
>>>>
>>>> 	If the device here is going carrier up prior to having speed or
>>>> duplex available, then maybe it should call netdev_state_change() when
>>>> the duplex and speed are available, or delay calling netif_carrier_on().
>>> I have encountered this problem (NIC having carrier on before being able
>>> to detect speed/duplex and driver not notifying when speed/duplex
>>> becomes available) with netxen cards earlier. But it was eventually
>>> fixed in the driver by commit 9d01412ae76f ("netxen: Fix link event
>>> handling.") so this example rather supports what you said.
>>>
>>>                                                             Michal Kubecek
>> Thanks a lot.
>> I checked the commit 9d01412ae76f ("netxen: Fix link event
>> handling."). The symptoms are the same with mine.
>>
>> The root cause is different. In my problem, the root cause is that LINKS
>> register[]  can not provide link_up and link_speed at the same time.
>> There is a time span between link_up and link_speed.
> The LINK_UP and LINK_SPEED bits in the LINKS register for ixgbe HW are updated
> simultaneously. Do you have any proof to show the delay you are referring to
> as I am sure our HW engineers would like to know about it.
Sorry. I can not reproduce this problem locally. What I have is the 
feedback from the customer.

Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: no
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: yes
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: yes
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: yes
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: yes
Settings for eth0:
    Supported ports: [ TP ]
    Supported link modes:   100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Advertised link modes:  100baseT/Full
                            1000baseT/Full
                            10000baseT/Full
    Advertised pause frame use: No
    Advertised auto-negotiation: Yes
    Speed: 10000Mb/s
    Duplex: Full
    Port: Twisted Pair
    PHYAD: 0
    Transceiver: external
    Auto-negotiation: on
    MDI-X: Unknown
    Supports Wake-on: d
    Wake-on: d
    Current message level: 0x00000007 (7)
                   drv probe link
    Link detected: yes


I think the time span between link_up and link_speed lasts several seconds.

 From this function
/**
  * ixgbe_service_timer - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
static void ixgbe_service_timer(unsigned long data)
{
         struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
         unsigned long next_event_offset;

         /* poll faster when waiting for link */
         if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
                 next_event_offset = HZ / 10;
         else
                 next_event_offset = HZ * 2;

         /* Reset the timer */
         mod_timer(&adapter->service_timer, next_event_offset + jiffies);

         ixgbe_service_event_schedule(adapter);
}

The timer will check link state every 100ms. In this several seconds, 
the link state
is updated for about several dozens of times.
>
> What we have seen in the case of bonding is that with some link partners there
> may be a rapid link flap (up, down, up) and as result the bonding driver may
> report the speed as unknown if just so happens that the speed is checked during
> the period in which the interface is re-negotiating.
Sure. What we have done is to avoid link_up without link_speed. Unless both
link_up and link_speed are ready, the bonding driver will not be 
triggered to check
both link_up and link_speed in 802.3ad mode.

Thanks a lot.
Zhu Yanjun
> Thanks,
> Emil
>   
>> My solution is to force to synchronize link_up and link_speed in ixgbe X540 NIC.
>>
>> Best Regards!
>> Zhu Yanjun
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
