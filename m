From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 6/8] ixgbe: add syfs interface for to export read
 only driver information
Date: Tue, 01 May 2012 10:02:41 -0400 (EDT)
Message-ID: <20120501.100241.1409452912879198250.davem@davemloft.net>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab2EAOCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 10:02:51 -0400
In-Reply-To: <1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  1 May 2012 01:51:07 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> This patch exports non-thermal (which was done via hwmon in an earlier
> patch) data to sysfs which isn't readily available elsewhere.  All of the
> fields are read only as this interface is to only export driver data.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I don't like it.

Some of this stuff is generic and belongs somewhere like ethtool, for
example the descriptor sizes and queue sizes.

The others are reading registers, and we have an ethtool API for that
already.

But putting anything like this in sysfs is pointless, because the
stuff that other cards have too will then go into differently named
sysfs files which, as is oft repeated here, is a terrible user
experience.

If you want to do this right, add a new ethtool interface that allows
the publication of card specific unchanging values, in a style like
what we already do for statistics.  Have one query that gets the
string list, and then another which fetches the actual values.

I hate sysfs, don't send me any more patches that add sysfs files for
networking devices. :-)
