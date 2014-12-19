From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:26:38 -0800
Message-ID: <20141218232638.354030ae@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:38966 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaLSH0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:26:49 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so651257pac.36
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:26:48 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +/**
> + * \brief Alloc net device
> + * @param size Size to allocate
> + * @param nq how many queues
> + * @returns pointer to net device structure
> + */
> +static inline struct net_device *liquidio_alloc_netdev(int size, int nq)
> +{
> +	if (nq > 1)
> +		return alloc_netdev_mq(size, "lio%d", NET_NAME_UNKNOWN,
> +				       ether_setup, nq);
> +	else
> +		return alloc_netdev(size, "lio%d", NET_NAME_UNKNOWN,
> +				    ether_setup);
> +}

There is no need for the (nq > 1) test, just do:
> +		return alloc_netdev_mq(size, "lio%d", NET_NAME_UNKNOWN,
> +				       ether_setup, nq);

Also, why does this device not have standard ethernet naming?
