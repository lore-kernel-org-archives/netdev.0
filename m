From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] neigh: use NEIGH_VAR_INIT in ndo_neigh_setup
 functions.
Date: Mon, 13 Jan 2014 11:35:38 -0800 (PST)
Message-ID: <20140113.113538.1561843824076418241.davem@davemloft.net>
References: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@trained-monkey.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbaAMTfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:35:38 -0500
In-Reply-To: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Jan 2014 14:13:47 +0100

> When ndo_neigh_setup is called, the bitfield used by NEIGH_VAR_SET is
> not initialized yet. This might cause confusion for the people who use
> NEIGH_VAR_SET in ndo_neigh_setup. So rather introduce NEIGH_VAR_INIT for
> usage in ndo_neigh_setup.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Wouldn't it be better to move the neigh_parms_data_state_cleanall() call
before we invoke ->ndo_neigh_setup()?  It seems that this code intended
to work that way, no?
