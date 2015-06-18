From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3 v4] net: track link-status of ipv4 nexthops
Date: Thu, 18 Jun 2015 03:26:30 -0700 (PDT)
Message-ID: <20150618.032630.1483876648100612079.davem@davemloft.net>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
	<1434386001-1157-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbbFRKOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 06:14:51 -0400
In-Reply-To: <1434386001-1157-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Mon, 15 Jun 2015 12:33:19 -0400

> @@ -1107,9 +1107,10 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  	struct in_device *in_dev;
>  	struct net *net = dev_net(dev);
> +	unsigned flags;

Please always fully spell out "unsigned int" instead of shortening it to
just "unsigned", thanks.

> @@ -920,11 +926,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>  		if (!nh->nh_dev)
>  			goto failure;
>  	} else {
> +		int linkdown = 0;
>  		change_nexthops(fi) {

Please put an empty line between local variable declarations and
code.
