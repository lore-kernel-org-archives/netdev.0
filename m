From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH0/12] qlge: More features and cleanup.
Date: Tue, 10 Mar 2009 04:46:03 -0700 (PDT)
Message-ID: <20090310.044603.190103058.davem@davemloft.net>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751749AbZCJLqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 07:46:18 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
	<1236632368-22079-6-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon,  9 Mar 2009 13:59:16 -0700

> Attached are more qlge patches for adding features such as multi TXQ and
> LRO.
> I've also included 4 bug fixes, 3 of which I will also post to net-2.6
> in a separate series tomorrow.

All applied, thanks Ron, although one thing I think you should
get rid of:

> @@ -3354,6 +3351,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
>  	 * completion handler rx_rings.
>  	 */
>  	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
> +	netif_set_gso_max_size(qdev->ndev, 65536);
>  
>  	for (i = 0; i < qdev->tx_ring_count; i++) {
>  		tx_ring = &qdev->tx_ring[i];

65536 (defined by GSO_MAX_SIZE) is the default and it's really a good
idea to only use this override interface on chips that actaully have
restrictions and can't use the default.

I also don't see what this change had to do with adding TX
multiqueue support :-)  It wasn't mentioned in the commit log
message in any way either.  Please don't slip small things in
like this.

