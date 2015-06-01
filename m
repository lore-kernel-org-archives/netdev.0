From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy
 settings
Date: Sun, 31 May 2015 17:19:40 -0700 (PDT)
Message-ID: <20150531.171940.1635713770956335110.davem@davemloft.net>
References: <1432157730-26865-2-git-send-email-aparames@broadcom.com>
	<20150522.161511.1791346966770946099.davem@davemloft.net>
	<1433102046.6319.103.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aparames@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
	sbranden@broadcom.com, jdzheng@broadcom.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbbFAATl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 20:19:41 -0400
In-Reply-To: <1433102046.6319.103.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 31 May 2015 20:54:06 +0100

> On Fri, 2015-05-22 at 16:15 -0400, David Miller wrote:
>> From: Arun Parameswaran <aparames@broadcom.com>
>> Date: Wed, 20 May 2015 14:35:30 -0700
>> 
>> > When trying to configure the settings for PHY1, using commands
>> > like 'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' seems to
>> > modify other settings apart from the speed of the PHY1, in the
>> > above case.
>> > 
>> > The ethtool seems to query the settings for PHY0, and use this
>> > as the base to apply the new settings to the PHY1. This is
>> > causing the other settings of the PHY 1 to be wrongly
>> > configured.
>> > 
>> > The issue is caused by the '_ethtool_get_settings()' API, which
>> > gets called because of the 'ETHTOOL_GSET' command, is clearing
>> > the 'cmd' pointer (of type 'struct ethtool_cmd') by calling
>> > memset. This clears all the parameters (if any) passed for the
>> > 'ETHTOOL_GSET' cmd. So the driver's callback is always invoked
>> > with 'cmd->phy_address' as '0'.
>> > 
>> > The '_ethtool_get_settings()' is called from other files in the
>> > 'net/core'. So the fix is applied to the 'ethtool_get_settings()'
>> > which is only called in the context of the 'ethtool'.
>> > 
>> > Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
>> > Reviewed-by: Ray Jui <rjui@broadcom.com>
>> > Reviewed-by: Scott Branden <sbranden@broadcom.com>
>> 
>> Applied and queued up for -stable, thanks.
> 
> Please revert this.  This is an incompatible API change, not a bug fix.
> The established semantics are that 'phyad' is filled in by the driver;
> it is not a parameter to the ETHTOOL_GSET command.

But then how in the world can the user specify specific PHY ADs for
a device that will respond to more than one?
