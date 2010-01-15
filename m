From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: set_sg should not be set for !F_SG drivers
Date: Fri, 15 Jan 2010 00:38:45 -0800 (PST)
Message-ID: <20100115.003845.98627674.davem@davemloft.net>
References: <20100115053229.31542.51066.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755359Ab0AOIif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:38:35 -0500
In-Reply-To: <20100115053229.31542.51066.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 15 Jan 2010 11:02:29 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> set_sg should not be set to ethtool_op_set_sg() by drivers
> that do not support SG. It is also not required for these
> drivers to set get_sg since it is handled by the generic
> ethtool_op_get_sg.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
 ...
> diff -ruNp org/drivers/net/r8169.c new/drivers/net/r8169.c
> --- org/drivers/net/r8169.c	2009-12-29 18:32:57.000000000 +0530
> +++ new/drivers/net/r8169.c	2009-12-29 18:34:32.000000000 +0530
> @@ -1253,7 +1253,6 @@ static const struct ethtool_ops rtl8169_
>  	.get_rx_csum		= rtl8169_get_rx_csum,
>  	.set_rx_csum		= rtl8169_set_rx_csum,
>  	.set_tx_csum		= ethtool_op_set_tx_csum,
> -	.set_sg			= ethtool_op_set_sg,
>  	.set_tso		= ethtool_op_set_tso,
>  	.get_regs		= rtl8169_get_regs,
>  	.get_wol		= rtl8169_get_wol,

I think you have some false positives here, actually.

As in my reply to your tcp_sendmsg() patch, r8169.c's transmit
function does fully support segmented packets.

So I think what it's doing here is supporting SG but having
it off by default.

And that's exactly what you get by setting the ethtool_op_set_sg()
function here, and it might be the case that this is what the
other two drivers in your patch are trying to do.

At a minimum, the r8169.c part of this patch is wrong.
