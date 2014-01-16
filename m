From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] neigh: use NEIGH_VAR_INIT in ndo_neigh_setup
 functions.
Date: Thu, 16 Jan 2014 11:37:57 -0800 (PST)
Message-ID: <20140116.113757.135125089659188691.davem@davemloft.net>
References: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
	<20140113.113538.1561843824076418241.davem@davemloft.net>
	<20140116071519.GA2815@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@trained-monkey.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaAPTiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:38:00 -0500
In-Reply-To: <20140116071519.GA2815@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 16 Jan 2014 08:15:19 +0100

> Mon, Jan 13, 2014 at 08:35:38PM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Thu,  9 Jan 2014 14:13:47 +0100
>>
>>> When ndo_neigh_setup is called, the bitfield used by NEIGH_VAR_SET is
>>> not initialized yet. This might cause confusion for the people who use
>>> NEIGH_VAR_SET in ndo_neigh_setup. So rather introduce NEIGH_VAR_INIT for
>>> usage in ndo_neigh_setup.
>>> 
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>
>>Wouldn't it be better to move the neigh_parms_data_state_cleanall() call
>>before we invoke ->ndo_neigh_setup()?  It seems that this code intended
>>to work that way, no?
> 
> Even moving neigh_parms_data_state_cleanall before ndo_neigh_setup
> would not solve this. In ndo_neigh_setup the original default value is
> changed. If it is changed by NEIGH_VAR_SET, it touches data_state bit
> and it looks as if it was changed by user. That is not desired because
> default value change would be ignored for this device. Therefore there
> is need for NEIGH_VAR_INIT which does not touch data_state bit.

That makes sense, applied, thanks Jiri.
