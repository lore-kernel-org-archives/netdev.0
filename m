From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 02/13] atl1: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 21:33:34 -0500
Message-ID: <20080416213334.52592c83@osprey.hogchain.net>
References: <20080416233727.732025083@vyatta.com>
	<20080416233757.090004281@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Chris Snook <csnook@redhat.com>,
	netdev@vger.kernel.org, <atl1-devel@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([207.115.11.52]:52575 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750815AbYDQCdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 22:33:39 -0400
In-Reply-To: <20080416233757.090004281@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Apr 2008 16:37:29 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> Use netdev_alloc_skb for rx buffer allocation. This sets skb->dev
> and can be overriden for NUMA machines.
> 
> Compile tested only!

Works fine.

Acked-by: Jay Cliburn <jacliburn@bellsouth.net>

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/atlx/atl1.c	2008-04-16 14:42:38.000000000
> -0700 +++ b/drivers/net/atlx/atl1.c	2008-04-16
> 14:44:18.000000000 -0700 @@ -1742,7 +1742,8 @@ static u16
> atl1_alloc_rx_buffers(struct 
>  		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
>  
> -		skb = dev_alloc_skb(adapter->rx_buffer_len +
> NET_IP_ALIGN);
> +		skb = netdev_alloc_skb(adapter->netdev,
> +				       adapter->rx_buffer_len +
> NET_IP_ALIGN); if (unlikely(!skb)) {
>  			/* Better luck next round */
>  			adapter->net_stats.rx_dropped++;
> 
