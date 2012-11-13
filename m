From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/11] ixgbevf: Add flag to indicate when rx is in
 net poll
Date: Tue, 13 Nov 2012 14:20:05 -0500 (EST)
Message-ID: <20121113.142005.106273728495001348.davem@davemloft.net>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1352815405-751-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2KMTUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:20:07 -0500
In-Reply-To: <1352815405-751-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 13 Nov 2012 06:03:18 -0800

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> napi_gro_receive shouldn't be called from netpoll context.  Doing
> so was causing kernel panics when jumbo frames larger than 2K were set.
> Add a flag to check if the Rx ring processing is occurring from interrupt
> context or from netpoll context and call netif_rx() if in the polling
> context.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This is not a scalable solution.

It is not prudent to have every single driver do a check like
this.  If using GRO receive from netpoll causes problems,
then it's a generic issue rather than a driver specific one.
