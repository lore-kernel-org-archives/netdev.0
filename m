From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe: Question about Flow Control on 10G
Date: Wed, 15 Oct 2014 23:46:10 +0000
Message-ID: <87618083B2453E4A8714035B62D67992500E2880@FMSMSX105.amr.corp.intel.com>
References: <543D72FE.9090107@citrix.com>
 <87618083B2453E4A8714035B62D67992500E1865@FMSMSX105.amr.corp.intel.com>
 <543EC362.5060507@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: dom <dominic.curran@citrix.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25064 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbaJOXqi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 19:46:38 -0400
In-Reply-To: <543EC362.5060507@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: dom [mailto:dominic.curran@citrix.com]
>Sent: Wednesday, October 15, 2014 11:57 AM
>To: Tantilov, Emil S; Skidmore, Donald C;
>netdev@vger.kernel.org
>Subject: Re: ixgbe: Question about Flow Control on 10G
>
>On 10/14/2014 01:54 PM, Tantilov, Emil S wrote:
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>> owner@vger.kernel.org] On Behalf Of dom
>>> Sent: Tuesday, October 14, 2014 12:01 PM
>>> To: Skidmore, Donald C; netdev@vger.kernel.org
>>> Subject: ixgbe: Question about Flow Control on 10G
>>>
>>> Hi
>>>
>>> I have a question about the ixgbe driver's handling of
>>> 'ethtool -a ethX'
>>> when the NIC is using fibre.
>>>
>>> Specifically I don't understand the code introduced by this
>>> commit:
>>>
>>> commit 73d80953dfd1d5a92948005798c857c311c2834b
>>> Author: Don Skidmore <donald.c.skidmore@intel.com>
>>> Date:   Wed Jul 31 02:19:24 2013 +0000
>>> Subject: ixgbe: fix fc autoneg ethtool reporting.
>>>
>>> The function introduced the function:
>>>         ixgbe_device_supports_autoneg_fc()
>>>
>>> which gets called by
>>> ixgbe_get_pauseparam()/ixgbe_set_pauseparam().
>>>
>>> specifically there is a  case in
>>> ixgbe_device_supports_autoneg_fc()
>>>
>>>      case ixgbe_media_type_fiber_qsfp:
>>>      case ixgbe_media_type_fiber:
>>>          hw->mac.ops.check_link(hw, &speed, &link_up,
>>> false);
>>>          /* if link is down, assume supported */
>>>          if (link_up)
>>>              supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
>>>                  true : false;
>>>
>>> If link_up=1 then why is supported only true for a
>>> speed=IXGBE_LINK_SPEED_1GB_FULL ?
>>>
>>> Why is Flow Control not supported for IXGBE_LINK_SPEED_10GB_FULL ?
>> For SFP modules (media_type_fiber) flow control autoneg is not supported at 10gig.
>> You can still set flow control manually to enabled/disabled, just not autoneg.
>>
>> Thanks,
>> Emil
>Hi Emil
>
>Thank you for the quick answer.  I have a one follow-up question if I may...
>
>We noticed that back in 3.2.9 (before 73d80953dfd basically) the
>behaviour was different for 10G fibre.  i.e.  autonegotiate showed 'on'.
>
># ethtool -a eth1
>Pause parameters for eth1:
>Autonegotiate:  on
>RX:             on
>TX:             on
>
>
>The code:
>     if (hw->fc.disable_fc_autoneg ||
>         (hw->fc.current_mode == ixgbe_fc_none))
>         pause->autoneg = 0;
>     else
>         pause->autoneg = 1;
>
>So I assume this old output from 'ethtool -a' for autogen was just
>wrong, is that correct ?

Correct.

Thanks,
Emil

>
>[I'm asking cos I _know_ my h/w collegues are going to ask why the change.]
>
>Thanks again
>dom
