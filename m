From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] sunvnet: bug fixes
Date: Thu, 06 Nov 2014 15:17:07 -0500 (EST)
Message-ID: <20141106.151707.412550919087651686.davem@davemloft.net>
References: <20141106195054.GD6238@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, ben@decadent.org.uk,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaKFURK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 15:17:10 -0500
In-Reply-To: <20141106195054.GD6238@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 6 Nov 2014 14:50:54 -0500

> This patch series has a coding-style fix and a bug fix.
> 
> The coding style fix (patch 1) is the extra indentation flagged by
> Ben Hutchings:
>   http://marc.info/?l=linux-netdev&m=141529243409594&w=2
> 
> The bugfix (patch 2) is the following: 
> when vnet_event_napi() is  called as part of napi_resume 
> (i.e., continuation of a previous NAPI read that was truncated 
> due to budget constraints), and then finds no more packets to read, 
> the code was trying to avoid an additional trip through ldc_rx 
> as an optimization. However, when this corner case happens, we would
> need to reset a number of dring state bits such as rcv_nxt carefully, 
> which quickly becomes complex and hacky.  The cleaner solution
> is to just roll back to vnet_poll, re-enable interrupts and set up
> dring state as was done in the pre-NAPI version of the driver.

Series applied, thanks.
