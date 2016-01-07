From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 18:28:49 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250504865@FMSMSX105.amr.corp.intel.com>
References: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
 <1586.1450389436@famine> <20151228084331.GA22747@unicorn.suse.cz>
 <5680FE85.60200@gmail.com>
 <87618083B2453E4A8714035B62D6799250503CE1@FMSMSX105.amr.corp.intel.com>
 <568C846E.6020304@gmail.com>
 <87618083B2453E4A8714035B62D67992505043B1@FMSMSX105.amr.corp.intel.com>
 <568E1801.9020804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: zhuyj <zyjzyj2000@gmail.com>, Michal Kubecek <mkubecek@suse.cz>,
	"Jay Vosburgh" <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8640 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbcAGS3R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 13:29:17 -0500
In-Reply-To: <568E1801.9020804@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: zhuyj [mailto:zyjzyj2000@gmail.com]
>Sent: Wednesday, January 06, 2016 11:47 PM
>To: Tantilov, Emil S; Michal Kubecek; Jay Vosburgh
>Cc: vfalico@gmail.com; gospo@cumulusnetworks.com; netdev@vger.kernel.org;
>Shteinbock, Boris (Wind River)
>Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>
>On 01/07/2016 10:43 AM, Tantilov, Emil S wrote:
>>> -----Original Message-----
>>> From: zhuyj [mailto:zyjzyj2000@gmail.com]
>>> Sent: Tuesday, January 05, 2016 7:05 PM
>>> To: Tantilov, Emil S; Michal Kubecek; Jay Vosburgh
>>> Cc: vfalico@gmail.com; gospo@cumulusnetworks.com;
>netdev@vger.kernel.org;
>>> Shteinbock, Boris (Wind River)
>>> Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>>>
>>> On 01/06/2016 09:26 AM, Tantilov, Emil S wrote:
>>>>> -----Original Message-----
>>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org]
>>> On
>>>>> Behalf Of zhuyj
>>>>> Sent: Monday, December 28, 2015 1:19 AM
>>>>> To: Michal Kubecek; Jay Vosburgh
>>>>> Cc: vfalico@gmail.com; gospo@cumulusnetworks.com;
>>> netdev@vger.kernel.org;
>>>>> Shteinbock, Boris (Wind River)
>>>>> Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
>>>>>
>>>>> On 12/28/2015 04:43 PM, Michal Kubecek wrote:
>>>>>> On Thu, Dec 17, 2015 at 01:57:16PM -0800, Jay Vosburgh wrote:
>>>>>>> <zyjzyj2000@gmail.com> wrote:
>>>>>>>> In 802.3ad mode, the speed and duplex is needed. But in some NIC,
>>>>>>>> there is a time span between NIC up state and getting speed and
>>> duplex.
>>>>>>>> As such, sometimes a slave in 802.3ad mode is in up state without
>>>>>>>> speed and duplex. This will make bonding in 802.3ad mode can not
>>>>>>>> work well.
>>>>>>>> To make bonding driver be compatible with more NICs, it is
>>>>>>>> necessary to restrict the up state in 802.3ad mode.
>>>>>>> 	What device is this?  It seems a bit odd that an Ethernet
>device
>>>>>>> can be carrier up but not have the duplex and speed available.
>>>>>> ...
>>>>>>> 	In general, though, bonding expects a speed or duplex change to
>>>>>>> be announced via a NETDEV_UPDATE or NETDEV_UP notifier, which would
>>>>>>> propagate to the 802.3ad logic.
>>>>>>>
>>>>>>> 	If the device here is going carrier up prior to having speed or
>>>>>>> duplex available, then maybe it should call netdev_state_change()
>when
>>>>>>> the duplex and speed are available, or delay calling
>>> netif_carrier_on().
>>>>>> I have encountered this problem (NIC having carrier on before being
>>> able
>>>>>> to detect speed/duplex and driver not notifying when speed/duplex
>>>>>> becomes available) with netxen cards earlier. But it was eventually
>>>>>> fixed in the driver by commit 9d01412ae76f ("netxen: Fix link event
>>>>>> handling.") so this example rather supports what you said.
>>>>>>
>>>>>>                                                              Michal
>>> Kubecek
>>>>> Thanks a lot.
>>>>> I checked the commit 9d01412ae76f ("netxen: Fix link event
>>>>> handling."). The symptoms are the same with mine.
>>>>>
>>>>> The root cause is different. In my problem, the root cause is that
>LINKS
>>>>> register[]  can not provide link_up and link_speed at the same time.
>>>>> There is a time span between link_up and link_speed.
>>>> The LINK_UP and LINK_SPEED bits in the LINKS register for ixgbe HW are
>>> updated
>>>> simultaneously. Do you have any proof to show the delay you are
>referring
>>> to
>>>> as I am sure our HW engineers would like to know about it.
>>> Sorry. I can not reproduce this problem locally. What I have is the
>>> feedback from the customer.
>> So you are assuming that there is a delay due to the issue you are
>seeing?
>>
>>> Settings for eth0:
>>>     Supported ports: [ TP ]
>>>     Supported link modes:   100baseT/Full
>>>                             1000baseT/Full
>>>                             10000baseT/Full
>>>     Supported pause frame use: No
>>>     Supports auto-negotiation: Yes
>>>     Advertised link modes:  100baseT/Full
>>>                             1000baseT/Full
>>>                             10000baseT/Full
>>>     Advertised pause frame use: No
>>>     Advertised auto-negotiation: Yes
>>>     Speed: Unknown!
>>>     Duplex: Unknown! (255)
>>>     Port: Twisted Pair
>>>     PHYAD: 0
>>>     Transceiver: external
>>>     Auto-negotiation: on
>>>     MDI-X: Unknown
>>>     Supports Wake-on: d
>>>     Wake-on: d
>>>     Current message level: 0x00000007 (7)
>>>                    drv probe link
>>>     Link detected: yes
>> The speed and the link state here are reported from
>> different sources:
>>
>>>     Link detected: yes
>> Comes from a netif_carrier_ok() check. This is done via
>ethtool_op_get_link().
>>
>> Only the speed is reported through the LINKS register - that is why it is
>reported
>> as "Unknown" - in other words link_up is false.
>>
>> This is a trace from the case where the bonding driver reports 0 Mbps:
>>
>>     kworker/u48:1-27950 [010] ....  6493.084916: ixgbe_service_task:
>eth1: link_speed = 80, link_up = false
>>     kworker/u48:1-27950 [011] ....  6493.184894: ixgbe_service_task:
>eth1: link_speed = 80, link_up = false
>>     kworker/u48:1-27950 [000] ....  6494.439883: ixgbe_service_task:
>eth1: link_speed = 80, link_up = true
>>     kworker/u48:1-27950 [000] ....  6494.464204: ixgbe_service_task:
>eth1: NIC Link is Up 10 Gbps, Flow Control: RX/TX
>>       kworker/0:2-1926  [000] ....  6494.464249: ixgbe_get_settings:
>eth1: link_speed = 80, link_up = false
>>    NetworkManager-3819  [008] ....  6494.464484: ixgbe_get_settings:
>eth1: link_speed = 80, link_up = false
>>     kworker/u48:1-27950 [007] ....  6494.496886: bond_mii_monitor: bond0:
>link status definitely up for interface eth1, 0 Mbps full duplex
>>    NetworkManager-3819  [008] ....  6494.496967: ixgbe_get_settings:
>eth1: link_speed = 80, link_up = false
>>     kworker/u48:1-27950 [008] ....  6495.288798: ixgbe_service_task:
>eth1: link_speed = 80, link_up = true
>>     kworker/u48:1-27950 [008] ....  6495.388806: ixgbe_service_task:
>eth1: link_speed = 80, link_up = true
>
>Hi, Emil
>
>Thanks for your feedback.
> From your log, I think the following can explain why bonding driver can
>not get speed.
>
>bonding                           ixgbe
>.                                   .
>.      <-----------------------   NETDEV_UP
>.                                   .
>bond_slave_netdev_event           NETDEV_DOWN
>.                                   .
>.                                   .
>.                                   .
>NETDEV_UP                           .
>.              ----------------> get_settings
>                                     .
>speed unknown  <---------------  link_up false
>.
>.
>link_up = true
>link_speed = unknown
>
>In the above, ixgbe is up and bonding gets this message, then bonding
>calls bond_slave_netdev_event while ixgbe is down.
>In bond_slave_netdev_event, bonding call get_settings in ixgbe to get
>link_speed. Since now ixgbe is down, so link_speed is
>unknown. In the end, bonding get the final state of ixgbe as link_up
>without link_speed.
>
>If you agree with me, would you like to help me to make tests with the
>following patch?
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>index d681273..3efc4d8 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>@@ -285,27 +285,24 @@ static int ixgbe_get_settings(struct net_device
>*netdev,
>         }
>
>         hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
>-       if (link_up) {
>-               switch (link_speed) {
>-               case IXGBE_LINK_SPEED_10GB_FULL:
>-                       ethtool_cmd_speed_set(ecmd, SPEED_10000);
>-                       break;
>-               case IXGBE_LINK_SPEED_2_5GB_FULL:
>-                       ethtool_cmd_speed_set(ecmd, SPEED_2500);
>-                       break;
>-               case IXGBE_LINK_SPEED_1GB_FULL:
>-                       ethtool_cmd_speed_set(ecmd, SPEED_1000);
>-                       break;
>-               case IXGBE_LINK_SPEED_100_FULL:
>-                       ethtool_cmd_speed_set(ecmd, SPEED_100);
>-                       break;
>-               default:
>-                       break;
>-               }
>-               ecmd->duplex = DUPLEX_FULL;
>-       } else {
>-               ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
>+
>+       ecmd->duplex = DUPLEX_FULL;
>+       switch (link_speed) {
>+       case IXGBE_LINK_SPEED_10GB_FULL:
>+               ethtool_cmd_speed_set(ecmd, SPEED_10000);
>+               break;
>+       case IXGBE_LINK_SPEED_2_5GB_FULL:
>+               ethtool_cmd_speed_set(ecmd, SPEED_2500);
>+               break;
>+       case IXGBE_LINK_SPEED_1GB_FULL:
>+               ethtool_cmd_speed_set(ecmd, SPEED_1000);
>+               break;
>+       case IXGBE_LINK_SPEED_100_FULL:
>+               ethtool_cmd_speed_set(ecmd, SPEED_100);
>+               break;
>+       default:
>                 ecmd->duplex = DUPLEX_UNKNOWN;
>+               break;
>         }
>
>         return 0;

This will break speed reporting. You cannot ignore link_up.
The speed is only valid when the link_up bit is set.

Thanks,
Emil
