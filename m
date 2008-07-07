From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 07 Jul 2008 09:51:30 +0800
Message-ID: <487176A2.6080604@cn.fujitsu.com>
References: <20080706130801.6bc36cf7@infradead.org>	<20080706.155318.46569612.davem@davemloft.net> <20080706165655.0783348b@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57271 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbYGGB4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 21:56:21 -0400
In-Reply-To: <20080706165655.0783348b@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven said the following on 2008-7-7 7:56:
> +void netdev_drivername(struct net_device *dev, char *buffer, int len)
> +{
> +	struct device_driver *driver;
> +	struct device *parent;
> +	struct ethtool_drvinfo info;
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> +
> +	if (len <= 0)
> +		return;
> +	buffer[0] = 0;
> +
> +	if (ops->get_drvinfo) {

if (ops && ops->get_drvinfo)

> +		memset(&info, 0, sizeof(info));
> +		info.cmd = ETHTOOL_GDRVINFO;
> +		ops->get_drvinfo(dev, &info);
> +		strlcpy(buffer, info.driver, len);
> +		if (strlen(info.driver) > 0)
> +			return;
> +	}

seems the logic should be:
if (strlen(info.driver) > 0) {
	strlcpy(buffer, info.driver, len);
	return;
}

