From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo
 dump size
Date: Wed, 18 May 2011 18:09:13 -0400 (EDT)
Message-ID: <20110518.180913.273729651812642114.davem@davemloft.net>
References: <20110518155410.28491.62723.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467Ab1ERWJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:09:25 -0400
In-Reply-To: <20110518155410.28491.62723.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Wed, 18 May 2011 08:54:11 -0700

> The message size allocated for rtnl info dumps was limited to a single
> page.  This is not enough for additional interface info available with
> devices that support SR-IOV.  Calculate the amount of data required so
> the dump can allocate enough data to satisfy the request.
> 
> V2 added the calcit function to the rtnl_register calls so that
> dump functions could get the minimum dump allocation size if they
> needed to.
> 
> V3 leverages the fact that the netdev register function ends up
> calling if_nlmsg_size.  We collect the minimum dump allocation size
> there and keep it in a module static variable so that the calcit
> function doesn't have to search for the device on every info dump.
> 
> V4 fixes the title.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

This only works if someone does a plain GETLINK request on the largest
space requiring device before the dump request happens.

Otherwise the value used by the calcit function won't be properly
prepared yet.
