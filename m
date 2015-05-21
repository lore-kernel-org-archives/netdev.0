From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] cxgb4: Add support for loopback between
 VI of same port
Date: Thu, 21 May 2015 15:30:29 -0400 (EDT)
Message-ID: <20150521.153029.774385014187583893.davem@davemloft.net>
References: <1431859523-7423-2-git-send-email-hariprasad@chelsio.com>
	<20150517.234613.463972132331185537.davem@davemloft.net>
	<4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797AbbEUTab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 15:30:31 -0400
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 21 May 2015 16:36:00 +0000

> I definitely understand the issue of wanting to avoid randomly
> different module parameters in various drivers which do similar
> things.  What we're looking for is a list of the acceptable ways for
> doing things ― especially when they don't fit current
> ethtool/ioctl() mechanisms.

The prevailing assumption is that it's OK to have configuration
settings that can't be undone.

And that's bogus from the beginning.

Drivers that have such situations are extremely painful for large
scale organizations, and I think you probably have no idea how
much of a huge hassle is created by features that can't be undone
or disabled at run time.

It is not feasible to reboot every machine in one's datacenter to turn
off a feature that's causing problems.  Yet that's what some large
scale organizations end up having to do, and it's COMPLETELY NOT
ACCEPTABLT that they have to do this.

So instead of trying to figure out ways to use things other than
ethtool, work instead to eliminate all situations where a feature
cannot be disabled/undone after probe time.
