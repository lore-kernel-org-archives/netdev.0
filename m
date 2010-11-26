From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ehea: Add some info messages and fix an issue
Date: Fri, 26 Nov 2010 09:01:48 -0800
Message-ID: <1290790908.11971.303.camel@Joe-Laptop>
References: <1290788771-10019-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1862 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300Ab0KZRBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 12:01:50 -0500
In-Reply-To: <1290788771-10019-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-11-26 at 14:26 -0200, leitao@linux.vnet.ibm.com wrote:
> This patch adds some debug information about ehea not being able to
> allocate enough spaces. Also it correctly updates the amount of available
> skb.

This patch introduces unnecessary whitespace into the logging messages.

> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
[]
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
[]
> @@ -400,6 +400,8 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
>  			skb_arr_rq1[index] = netdev_alloc_skb(dev,
>  							      EHEA_L_PKT_SIZE);
>  			if (!skb_arr_rq1[index]) {
> +				ehea_info("Unable to allocate enough skb in
> +					   the array\n");

Don't split up the message into multiple lines like this.
Either just use a single line like:

				ehea_info("Unable to allocate enough skb in the array\n");

and ignore 80 column line lengths, or break up the line into
quoted parts:

				ehea_info("Unable to allocate enough skb in"
					  "the array\n");

The first option is preferred to make grepping easier.

[]

> @@ -735,8 +744,11 @@ static int ehea_proc_rwqes(struct net_device *dev,
>  
>  					skb = netdev_alloc_skb(dev,
>  							       EHEA_L_PKT_SIZE);
> -					if (!skb)
> +					if (!skb) {
> +						ehea_info("Not enough memory to
> +							   allocate skb\n");

here too


