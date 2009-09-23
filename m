From: Ben Greear <greearb@candelatech.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 14:56:09 -0700
Message-ID: <4ABA9979.2070808@candelatech.com>
References: <4ABA4F8B.6040504@candelatech.com> <1253730766.2538.28.camel@localhost.localdomain> <4ABA9509.7000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42122 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZIWV4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 17:56:05 -0400
In-Reply-To: <4ABA9509.7000008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm poking at the ixgbe_main code in 2.6.31.

It seems from the spec sheet that the 82599 supports the GORCH.


	/* 82598 hardware only has a 32 bit counter in the high register */
	if (hw->mac.type == ixgbe_mac_82599EB) {
		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */


stats.gorc is 64-bit, so any reason not to grab the 4 high-bits out of GORCL
and add them to stats.gorc instead of just clearing them as this
code seems to do?

That gives us some precious extra seconds to read counters before they
wrap :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

