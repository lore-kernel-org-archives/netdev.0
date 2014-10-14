From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe: Question about Flow Control on 10G
Date: Tue, 14 Oct 2014 20:54:26 +0000
Message-ID: <87618083B2453E4A8714035B62D67992500E1865@FMSMSX105.amr.corp.intel.com>
References: <543D72FE.9090107@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: dom <dominic.curran@citrix.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2760 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbaJNUya convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:54:30 -0400
In-Reply-To: <543D72FE.9090107@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of dom
>Sent: Tuesday, October 14, 2014 12:01 PM
>To: Skidmore, Donald C; netdev@vger.kernel.org
>Subject: ixgbe: Question about Flow Control on 10G
>
>Hi
>
>I have a question about the ixgbe driver's handling of
>'ethtool -a ethX'
>when the NIC is using fibre.
>
>Specifically I don't understand the code introduced by this
>commit:
>
>commit 73d80953dfd1d5a92948005798c857c311c2834b
>Author: Don Skidmore <donald.c.skidmore@intel.com>
>Date:   Wed Jul 31 02:19:24 2013 +0000
>Subject: ixgbe: fix fc autoneg ethtool reporting.
>
>The function introduced the function:
>        ixgbe_device_supports_autoneg_fc()
>
>which gets called by
>ixgbe_get_pauseparam()/ixgbe_set_pauseparam().
>
>specifically there is a  case in
>ixgbe_device_supports_autoneg_fc()
>
>     case ixgbe_media_type_fiber_qsfp:
>     case ixgbe_media_type_fiber:
>         hw->mac.ops.check_link(hw, &speed, &link_up,
>false);
>         /* if link is down, assume supported */
>         if (link_up)
>             supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
>                 true : false;
>
>If link_up=1 then why is supported only true for a
>speed=IXGBE_LINK_SPEED_1GB_FULL ?
>
>Why is Flow Control not supported for IXGBE_LINK_SPEED_10GB_FULL ?

For SFP modules (media_type_fiber) flow control autoneg is not supported at 10gig. You can still set flow control manually to enabled/disabled, just not autoneg.

Thanks,
Emil
