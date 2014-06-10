From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:28:34 -0700
Message-ID: <20140610102834.450effd6@nehalam.linuxnetplumber.net>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	patches@linaro.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:42691 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaFJR2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:28:37 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so1033802pdb.2
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:28:37 -0700 (PDT)
In-Reply-To: <20140610010803.18695.88446.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 09:08:03 +0800
Andy Green <andy.green@linaro.org> wrote:

> +static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
> +{
> +	struct ogma_ndev *ndev = netdev_priv(net_device);
> +
> +	if (!ndev->priv->param.use_jumbo_pkt_flag)
> +		return eth_change_mtu(net_device, new_mtu);
> +
> +	if ((new_mtu < 68) || (new_mtu > 9000))
> +		return -EINVAL;
> +
> +	net_device->mtu = new_mtu;
> +
> +	return 0;
> +}
> +

I don't think this works. rx_pkt_buf_len is only set at probe time.

Don't you need to:
 1. Stop device if running
 2. Free existing receive buffers
 3. change rx_pkt_buf_len
 4. Refill restart receiver.

Most devices setup receive ring in open (not probe)
to handle this. It also avoid grabbing memory if device is unused.
