From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Wed, 3 May 2017 22:21:11 -0700
Message-ID: <20170503222111.749ce90b@xeon-e3>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35738 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932207AbdEDFVO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 01:21:14 -0400
Received: by mail-pf0-f174.google.com with SMTP id v14so2277442pfd.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 22:21:14 -0700 (PDT)
In-Reply-To: <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 May 2017 14:44:35 +1000
Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:

> +void ncsi_ethtool_register_dev(struct net_device *dev)
> +{
> +	struct ethtool_ops *ops;
> +
> +	ops = (struct ethtool_ops *)(dev->ethtool_ops);
> +	if (!ops)
> +		return;
> +
> +	ops->get_ncsi_channels = ncsi_get_channels;
> +}
> +

Instead of casting away const which opens up potential security
issues. Have two ethtool_ops structures.
