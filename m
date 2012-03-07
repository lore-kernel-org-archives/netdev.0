From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: restore multicast and rx_errors fields
Date: Wed, 7 Mar 2012 11:17:04 -0300
Message-ID: <20120307141704.GA11924@oc1711230544.ibm.com>
References: <1331099201.2474.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Anton Blanchard <anton@samba.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:50220 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757818Ab2CGORP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 09:17:15 -0500
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 7 Mar 2012 11:17:13 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id ADC19352004A
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 11:17:09 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q27EH6xD12059088
	for <netdev@vger.kernel.org>; Wed, 7 Mar 2012 11:17:06 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q27CH2Vb012676
	for <netdev@vger.kernel.org>; Wed, 7 Mar 2012 09:17:03 -0300
Content-Disposition: inline
In-Reply-To: <1331099201.2474.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 09:46:41PM -0800, Eric Dumazet wrote:
> Commit 239c562c94d (ehea: Add 64bit statistics) added a regression,
> since we no longer report multicast & rx_errors fields, taken from
> port->stats structure. These fields are updated in ehea_update_stats()
> every second.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Anton Blanchard <anton@samba.org>
> Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea_main.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> index 5d5fb26..e6893cd 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -336,7 +336,9 @@ static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
>  	stats->tx_bytes = tx_bytes;
>  	stats->rx_packets = rx_packets;
> 
> -	return &port->stats;
> +	stats->multicast = port->stats.multicast;
> +	stats->rx_errors = port->stats.rx_errors;
> +	return stats;
>  }
> 
>  static void ehea_update_stats(struct work_struct *work)
> 
> 

Tested, in particular, the multicast stat, pinging 224.0.0.1 from
another machine.

Thanks.
Cascardo.

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
