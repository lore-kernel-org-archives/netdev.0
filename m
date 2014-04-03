From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Thu, 03 Apr 2014 11:19:14 -0400 (EDT)
Message-ID: <20140403.111914.2151023252588766039.davem@davemloft.net>
References: <1396333381-7252-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, cwang@twopensource.com,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbaDCPRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:17:41 -0400
In-Reply-To: <1396333381-7252-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Tue,  1 Apr 2014 09:23:01 +0300

> If the vxlan interface is created without explicit group definition,
> there are corner cases which may cause kernel panic.
> 
> For instance, in the following scenario:
 ...
> When vxlan interface is created without explicit group definition, the
> default_dst protocol family is initialiazed to AF_UNSPEC and the driver
> assumes IPv4 configuration. On the other side, the default_dst protocol
> family is used to differentiate between IPv4 and IPv6 cases and, since,
> AF_UNSPEC != AF_INET, the processing takes the IPv6 path.
> 
> Making the IPv4 assumption explicit by settting default_dst protocol
> family to AF_INET4 and preventing mixing of IPv4 and IPv6 addresses in
> snooped fdb entries fixes the corner case crashes.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
> 
> This can happen starting from 3.12 when IPv6 support was merged to vxlan.

Looks good to me, thanks for following up on this.

Applied and queued up for -stable.
