From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 01/11] fjes: Add trace-gathering facility
Date: Mon, 11 Apr 2016 13:59:53 +0200
Message-ID: <20160411115953.GB2175@nanopsycho.orion>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1460362197-15033-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37460 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbcDKL74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 07:59:56 -0400
Received: by mail-wm0-f45.google.com with SMTP id n3so101233413wmn.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 04:59:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460362197-15033-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 11, 2016 at 10:09:57AM CEST, izumi.taku@jp.fujitsu.com wrote:
>This patch introduces trace-gathering facility via ioctl.
>This data is useful for debugging this module and firmware.
>
>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

<snip>


>@@ -61,6 +62,7 @@ fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
> static int fjes_change_mtu(struct net_device *, int);
> static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
> static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
>+static int fjes_ioctl(struct net_device *, struct ifreq *, int cmd);
> static void fjes_tx_retry(struct net_device *);
> 
> static int fjes_acpi_add(struct acpi_device *);
>@@ -242,6 +244,7 @@ static const struct net_device_ops fjes_netdev_ops = {
> 	.ndo_tx_timeout		= fjes_tx_retry,
> 	.ndo_vlan_rx_add_vid	= fjes_vlan_rx_add_vid,
> 	.ndo_vlan_rx_kill_vid = fjes_vlan_rx_kill_vid,
>+	.ndo_do_ioctl		= fjes_ioctl,
> };

<snip>


>+
>+static int fjes_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
>+{
>+	switch (cmd) {
>+	case FJES_IOCTL_TRACE_START:
>+		return fjes_ioctl_trace_start(netdev, rq);
>+	case FJES_IOCTL_TRACE_STOP:
>+		return fjes_ioctl_trace_stop(netdev, rq);
>+	case FJES_IOCTL_TRACE_GETCFG:
>+		return fjes_ioctl_trace_getcfg(netdev, rq);
>+	default:
>+		return -EOPNOTSUPP;
>+	}
>+}

This ioctl tracing patch looks scarry to me. I don't think you should
add any functionality to ioctl today.
