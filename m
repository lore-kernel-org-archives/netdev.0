From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:11:30 -0800
Message-ID: <20141218231130.74dcad81@urahara>
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
Received: from mail-pd0-f176.google.com ([209.85.192.176]:56095 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaLSHLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:11:40 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so627544pdi.35
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:11:40 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +		if (packet_was_received) {
> +			lio->stats.rx_bytes += len;
> +			atomic64_inc((atomic64_t *)&lio->stats.rx_packets);
> +			netdev->last_rx = jiffies;
> +		} else {
> +			atomic64_inc((atomic64_t *)&lio->stats.rx_dropped);
> +			lio_info(lio, rx_err,
> +				 "netif_rxXX  error rx_dropped:%ld\n",
> +				 lio->stats.rx_dropped);
> +		}

What is point of keeping own statistics in atomic (which are slower)?
Just use dev->stats directly.
