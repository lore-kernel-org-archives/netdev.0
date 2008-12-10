From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Tue, 09 Dec 2008 23:22:45 -0800 (PST)
Message-ID: <20081209.232245.145580375.davem@davemloft.net>
References: <20081209210644.GC3785@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55333
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753607AbYLJHWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:22:44 -0500
In-Reply-To: <20081209210644.GC3785@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 9 Dec 2008 16:06:44 -0500

> Hey all-
> 	A few months back a race was discused between the netpoll napi service
> path, and the fast path through net_rx_action:
> http://kerneltrap.org/mailarchive/linux-netdev/2007/10/16/345470
> 
> A patch was submitted for that bug, but I think we missed a case.
> 
> Consider the following scenario:
> 
> INITIAL STATE
> CPU0 has one napi_struct A on its poll_list
> CPU1 is calling netpoll_send_skb and needs to call poll_napi on the same
> napi_struct A that CPU0 has on its list
> 
> 
> 
> CPU0						CPU1
> net_rx_action					poll_napi
> !list_empty (returns true)			locks poll_lock for A
> 						 poll_one_napi
> 						  napi->poll
> 						   netif_rx_complete
> 						    __napi_complete
> 						    (removes A from poll_list)
> list_entry(list->next)
> 
 ...
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Looks good, applied.

Thanks Neil!
