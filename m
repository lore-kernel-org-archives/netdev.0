From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Wed, 08 Jun 2011 17:01:41 -0700 (PDT)
Message-ID: <20110608.170141.15424428944606042.davem@davemloft.net>
References: <20110605.142823.1727360496050285755.davem@davemloft.net>
	<20110607161808.GA5018@midget.suse.cz>
	<BANLkTikmNXK=i1HhtGtb1+81rGqGgBQ8mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, kaber@trash.net, netdev@vger.kernel.org,
	pedro.netdev@dondevamos.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab1FIAFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:05:47 -0400
In-Reply-To: <BANLkTikmNXK=i1HhtGtb1+81rGqGgBQ8mA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 7 Jun 2011 18:25:23 -0700

> No, it's not true.  All drivers store the registered vlan filters in
> some way so that they can restore them when the device is reset.  This
> is currently done in one of two ways: storing a bitmap or iterating
> over the devices currently registered in a group.
> 
> The vlan code is moving away from directly accessing groups and no new
> drivers do this.  In fact, once all drivers are converted over groups
> will not even be registered on devices.  This is because otherwise
> there is quite a bit of vlan code in each driver, which leads to
> inconsistent behavior and bugs.
> 
> Really, all a driver needs to know is whether it should add a given
> vlan to its table, not what the upper layers plan to do with it.  So
> when ndo_vlan_rx_add_vid() is called it should add it to its CAM table
> and store it if it is needed to restore behavior after a reset, just
> as is done with all other configuration state.

Thanks for clearing all of this up Jesse.
