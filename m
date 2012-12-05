From: Ben Greear <greearb@candelatech.com>
Subject: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 13:35:01 -0800
Message-ID: <50BFBE05.7020408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53975 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab2LEVfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems the only way to get the current pci-e bus speed & width
in ixgbe (and probably many other NICs) is by parsing output
of lspci -vvv.

I'd personally find it easier if this info were available via
ethtool API.

Any opinions on adding this info?  I was thinking something like:

struct ethtool_bus_speed {
   u32 cur_speed; /* millions of transactions per sec, or Mhz for older PCI busses */
   u32 cur_width; /* bus width */

   /* Maximum values supported by NIC */
   u32 max_speed;
   u32 max_width;

   #define BELOW_OPTIMAL_SPEED 0x1  /* Set if NIC cannot run at max speed with current bus settings */
   u32 flags;

   /* Plenty of space to grow, set to zero until defined */
   u32 reserved[32];
};

This could also fit in the reserved space of the
struct ethtool_drvinfo if that were preferred (and
width and flags could be a u16 to save a bit of space
in that case).

Any opinions...or suggestions for other interesting bits to add?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
