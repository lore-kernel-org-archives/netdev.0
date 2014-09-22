From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] fec: Staticize fec_enet_select_queue()
Date: Mon, 22 Sep 2014 16:16:56 -0400 (EDT)
Message-ID: <20140922.161656.2073239522143660859.davem@davemloft.net>
References: <1411149574-26296-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbaIVURA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:17:00 -0400
In-Reply-To: <1411149574-26296-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Fri, 19 Sep 2014 14:59:34 -0300

> fec_enet_select_queue() is only used locally, so mark it as 'static' to fix the
> following sparse warning:
> 
> drivers/net/ethernet/freescale/fec_main.c:2707:5: warning: symbol 'fec_enet_select_queue' was not declared. Should it be static?
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Changes since v1:
> - Make checkpatch happy

Please just delete this function.

It's overriding code which does exactly the same thing.

Actually, more precisely, this code is duplicating code in a way that
bypasses many core facilitites of the networking.  For example, this
override means that socket based flow steering, XPS, etc. are all
not happening on these devices.

Without ->ndo_select_queue(), the flow dissector does __netdev_pick_tx
which is exactly what you want to happen.
