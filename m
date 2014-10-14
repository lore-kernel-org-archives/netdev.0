From: dom <dominic.curran@citrix.com>
Subject: ixgbe: Question about Flow Control on 10G
Date: Tue, 14 Oct 2014 12:01:18 -0700
Message-ID: <543D72FE.9090107@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <donald.c.skidmore@intel.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7769 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601AbaJNTA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2014 15:00:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have a question about the ixgbe driver's handling of 'ethtool -a ethX' 
when the NIC is using fibre.

Specifically I don't understand the code introduced by this commit:

commit 73d80953dfd1d5a92948005798c857c311c2834b
Author: Don Skidmore <donald.c.skidmore@intel.com>
Date:   Wed Jul 31 02:19:24 2013 +0000
Subject: ixgbe: fix fc autoneg ethtool reporting.

The function introduced the function:
        ixgbe_device_supports_autoneg_fc()

which gets called by ixgbe_get_pauseparam()/ixgbe_set_pauseparam().

specifically there is a  case in ixgbe_device_supports_autoneg_fc()

     case ixgbe_media_type_fiber_qsfp:
     case ixgbe_media_type_fiber:
         hw->mac.ops.check_link(hw, &speed, &link_up, false);
         /* if link is down, assume supported */
         if (link_up)
             supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
                 true : false;

If link_up=1 then why is supported only true for a 
speed=IXGBE_LINK_SPEED_1GB_FULL ?

Why is Flow Control not  supported for IXGBE_LINK_SPEED_10GB_FULL ?

I have search through the 82599 spec, but I can't find a reason.
Please can anyone help me understand ?

Thanks
dom
