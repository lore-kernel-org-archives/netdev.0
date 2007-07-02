From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/9] pasemi_mac: Clean TX ring in poll
Date: Mon, 02 Jul 2007 08:34:22 -0400
Message-ID: <4688F0CE.9020600@pobox.com>
References: <20070622194720.614405000@lixom.net> <20070622200501.GC11723@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51091 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbXGBMeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:34:24 -0400
In-Reply-To: <20070622200501.GC11723@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Clean the TX ring in the poll call, to avoid sitting on mapped buffers
> for a long time. NFS doesn't seem to like it much, for example.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> Index: netdev-2.6/drivers/net/pasemi_mac.c
> ===================================================================
> --- netdev-2.6.orig/drivers/net/pasemi_mac.c
> +++ netdev-2.6/drivers/net/pasemi_mac.c
> @@ -1052,6 +1052,7 @@ static int pasemi_mac_poll(struct net_de
>  	int pkts, limit = min(*budget, dev->quota);
>  	struct pasemi_mac *mac = netdev_priv(dev);
>  
> +	pasemi_mac_clean_tx(mac);
>  	pkts = pasemi_mac_clean_rx(mac, limit);

Why is this needed?  Is your TX interrupt mitigated or delayed somehow?

In general, drivers should only clean TX in one place.  Doing so in 
multiple places tends to indicate a bug somewhere.

You are correct that you should not sit on buffers for too long -- that 
increases latency of all who are waiting on those buffers to be sent.


