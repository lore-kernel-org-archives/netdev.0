From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] ldmvsw: Make sunvnet_common compatible
 with ldmvsw
Date: Fri, 11 Mar 2016 14:27:33 -0500 (EST)
Message-ID: <20160311.142733.1237549201193012342.davem@davemloft.net>
References: <cover.1457401532.git.Aaron.Young@oracle.com>
	<cover.1457401532.git.Aaron.Young@oracle.com>
	<85723889cbcaab6d1f72581f5d34b07c7dc67f6f.1457401532.git.Aaron.Young@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com
To: Aaron.Young@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbcCKT1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:27:36 -0500
In-Reply-To: <85723889cbcaab6d1f72581f5d34b07c7dc67f6f.1457401532.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <Aaron.Young@oracle.com>
Date: Tue,  8 Mar 2016 07:02:34 -0800

> @@ -719,12 +720,13 @@ static void maybe_tx_wakeup(struct vnet_port *port)
>  	__netif_tx_unlock(txq);
>  }
>  
> -static inline bool port_is_up(struct vnet_port *vnet)
> +inline bool port_is_up_common(struct vnet_port *vnet)

All of these things in foo.c files shouldn't have an inline attribute.

>  {
>  	struct vio_driver_state *vio = &vnet->vio;
>  
>  	return !!(vio->hs_state & VIO_HS_COMPLETE);
>  }
> +EXPORT_SYMBOL(port_is_up_common);

Especially if they are also exported.

Need to use EXPORT_SYMBOL_GPL() here as well, but I seriously think you need to rename
this function in order to not pollute the global namespace of exported kernel symbols.
You need to add a suitable prefix such as sunvnet_*() or whatever.
