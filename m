From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH cumulus-4.1.y 1/5] vxlan: flush fdb entries on oper down
Date: Mon, 23 Jan 2017 08:59:45 -0800
Message-ID: <20170123085945.36404cf0@xeon-e3>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        ramanb@cumulusnetworks.com, jbenc@redhat.com, pshelar@ovn.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34260 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdAWQ74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:59:56 -0500
Received: by mail-pf0-f171.google.com with SMTP id e4so42422527pfg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 08:59:56 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 23:40:06 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 19b1653..15b1c23 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -3276,6 +3276,12 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
>  		vxlan_handle_lowerdev_unregister(vn, dev);
>  	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
>  		vxlan_push_rx_ports(dev);
> +	else if (event == NETDEV_CHANGE) {
> +		if (dev->netdev_ops == &vxlan_netdev_ops) {
> +			if (netif_running(dev) && !netif_oper_up(dev))
> +				vxlan_flush(netdev_priv(dev));
> +		}
> +	}

Looks correct.
Maybe logic would be clearer with a switch() statement here.
