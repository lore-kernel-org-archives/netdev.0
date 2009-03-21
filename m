From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 22/77] usbnet: convert catc device to net_device_ops
Date: Sat, 21 Mar 2009 11:17:29 +0100
Message-ID: <20090321101728.GA3380@psychotron.englab.brq.redhat.com>
References: <20090321053527.316395697@vyatta.com> <20090321053714.207963951@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37145 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752878AbZCUKRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 06:17:40 -0400
Content-Disposition: inline
In-Reply-To: <20090321053714.207963951@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 21, 2009 at 06:35:49AM CET, shemminger@vyatta.com wrote:
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>--- a/drivers/net/usb/catc.c	2009-03-20 12:10:10.851651580 -0700
>+++ b/drivers/net/usb/catc.c	2009-03-20 12:10:23.060839265 -0700
>@@ -743,6 +743,18 @@ static int catc_stop(struct net_device *
> 	return 0;
> }
> 
>+static const struct net_device_ops catc_netdev_ops = {
>+	.ndo_open		= catc_open,
>+	.ndo_stop		= catc_stop,
>+	.ndo_start_xmit		= catc_start_xmit,
                                  ^^^^^^^^^^^^^^^
Shouldn't be here catc_hard_start_xmit() instead? Cannot find catc_start_xmit()
anywhere in the code...
>+
>+	.ndo_tx_timeout		= catc_tx_timeout,
>+	.ndo_set_multicast_list = catc_set_multicast_list,
>+	.ndo_change_mtu		= eth_change_mtu,
>+	.ndo_set_mac_address 	= eth_mac_addr,
>+	.ndo_validate_addr	= eth_validate_addr,
>+};
>+
> /*
>  * USB probe, disconnect.
>  */
>@@ -767,12 +779,8 @@ static int catc_probe(struct usb_interfa
> 
> 	catc = netdev_priv(netdev);
> 
>-	netdev->open = catc_open;
>-	netdev->hard_start_xmit = catc_hard_start_xmit;
>-	netdev->stop = catc_stop;
>-	netdev->tx_timeout = catc_tx_timeout;
>+	netdev->netdev_ops = &catc_netdev_ops;
> 	netdev->watchdog_timeo = TX_TIMEOUT;
>-	netdev->set_multicast_list = catc_set_multicast_list;
> 	SET_ETHTOOL_OPS(netdev, &ops);
> 
> 	catc->usbdev = usbdev;
>
>-- 
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
