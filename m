From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Wed, 3 May 2017 22:19:44 -0700
Message-ID: <20170503221944.1dd0d576@xeon-e3>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34882 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754126AbdEDFTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 01:19:54 -0400
Received: by mail-pg0-f51.google.com with SMTP id o3so2484234pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 22:19:53 -0700 (PDT)
In-Reply-To: <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 May 2017 14:44:35 +1000
Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:

> +static int ethtool_get_ncsi_channels(struct net_device *dev,
> +				     void __user *useraddr)

Please don't use an opaque type for this. See how other ethtool
operations take a struct.

> +{
> +	struct ethtool_ncsi_channels *enc;
> +	short nr_channels;
Should be __u16 or unsigned not short.

> +	ssize_t size = 0;
> +	int ret;
> +
> +	if (!dev->ethtool_ops->get_ncsi_channels)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&nr_channels, useraddr + sizeof(enc->cmd),
> +			   sizeof(nr_channels)))
> +		return -EFAULT;
> +
> +	size = sizeof(*enc);
> +	if (nr_channels > 0)
> +		size += nr_channels * sizeof(enc->id[0]);

You have no upper bound on number of channels, and therefore an incorrectly
application could grab an excessive amount of kernel memory.
