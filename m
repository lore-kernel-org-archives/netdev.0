From: "Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
Subject: RE: [E1000-devel] igb: question regarding auto-negotiation
Date: Thu, 4 Aug 2016 23:16:09 +0000
Message-ID: <2A35EA60C3C77D438915767F458D65688391472E@ORSMSX111.amr.corp.intel.com>
References: <579BE8C3.806@citrix.com>
	<CAKgT0UfAawN49bc5kWjnynHhA4rBddQOJ320SdaK57yDCNFb_A@mail.gmail.com>
 <57A3C953.6050403@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Dominic Curran <dominic.curran@citrix.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9067 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759193AbcHDXQL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 19:16:11 -0400
In-Reply-To: <57A3C953.6050403@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Dominic Curran [mailto:dominic.curran@citrix.com] 
Sent: Thursday, August 04, 2016 4:02 PM
To: Alexander Duyck <alexander.duyck@gmail.com>; e1000-devel@lists.sourceforge.net
Cc: Netdev <netdev@vger.kernel.org>
Subject: Re: [E1000-devel] igb: question regarding auto-negotiation



On 07/29/2016 09:35 PM, Alexander Duyck wrote:
> On Fri, Jul 29, 2016 at 4:37 PM, Dominic Curran
> <dominic.curran@citrix.com> wrote:
>> Hi
>>
>> This question refers to igb codebase.
>> I have a question regarding the setting of hw->mac.autoneg.
>>
>> Is it correct to say for igb driver:
>>     "if speed=1000 and duplex=FULL and media_type=COPPER  then  only
>> auto-negotiate enable is supported"
>>
>> i.e.
>>     with these settings (speed/duplex/media_type) then auto-negotiate can
>> _not_ be disabled.  Correct ?
>>
>> I say this for two reasons:
>> 1) The code in igb_set_spd_dplx() seems to indicate it:
>>
>>         case SPEED_1000 + DUPLEX_FULL:
>>                  mac->autoneg = 1;
>>                  adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
>>                  break;
>>
>> 2) Instrumenting the driver, I always see the autoneg code in
>> e1000_check_for_copper_link_generic()  get called after an igb_reset().
>>
>>
>> Have i understood correctly ?
>>
>> thanks in advance
>> dom
> If you are using copper then you are likely referring to 1000Base-T
> correct?  If so then autonegotation is a requirement.
>
> Here is the wikipedia URL that refers to this:
> https://en.wikipedia.org/wiki/Gigabit_Ethernet#1000BASE-T
>
> Hope this helps to clear it up.
>
> Thanks.
>
> - Alex

Thanks for reply.  I read the wiki link and a bunch of other links besides.

So I have a follow-up question:

You're right I am using copper and 1000Base-T, and as you say auto-neg 
is then requirement.

So why is it possible with the igb driver to set auto-neg to OFF ?

e.g.
# ethtool -a eth6
Pause parameters for eth6:
Autonegotiate:  on
RX:             on
TX:             on

Now turn it OFF:

# ethtool -A eth6 autoneg off

# ethtool -a eth6
Pause parameters for eth6:
Autonegotiate:  off
RX:             on
TX:             on

But added debug to the driver I _know_ that it is still 
auto-negotiating, and printing current settings indicates 
'Auto-negotiatiate' is on...

# ethtool  eth6
Settings for eth6:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 1
         Transceiver: internal
         Auto-negotiation: on <<<<
         MDI-X: on
         Supports Wake-on: pumbg
         Wake-on: d
         Current message level: 0x00000007 (7)
                                drv probe link
         Link detected: yes

So I dont understand the difference between these two values ??
Can anyone help please ?

Thanks
dom

Dom,

ethtool -A is used to set flow-control parameters, not speed/duplex/autoneg. Speed/duplex parameters are set with ethtool -s. man ethtool should help explain the difference.

I hope this helps,
Jeff
------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
