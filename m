From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: turn on device when extracting statistics
Date: Sun, 27 Nov 2016 20:29:45 -0500 (EST)
Message-ID: <20161127.202945.1759992980026862076.davem@davemloft.net>
References: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        andrew@lunn.ch, eric@nelint.com, tremyfr@gmail.com,
        johannes@sipsolutions.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, cphealy@gmail.com
To: nikita.yoush@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752675AbcK1B3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 20:29:48 -0500
In-Reply-To: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Fri, 25 Nov 2016 13:02:00 +0300

> +	int i, ret;
> +
> +	ret = pm_runtime_get_sync(&fep->pdev->dev);
> +	if (IS_ERR_VALUE(ret)) {
> +		memset(data, 0, sizeof(*data) * ARRAY_SIZE(fec_stats));
> +		return;
> +	}

This really isn't the way to do this.

When the device is suspended and the clocks are going to be stopped,
you must fetch the statistic values into a software copy and provide
those if the device is suspended when statistics are requested.
