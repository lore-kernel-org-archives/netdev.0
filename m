From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: Race condition in gratuitous ARP reception
 handling.
Date: Tue, 07 Mar 2017 13:43:38 -0800 (PST)
Message-ID: <20170307.134338.1195186271110286952.davem@davemloft.net>
References: <1488463187-17365-1-git-send-email-tomasz.dzieciol@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tomasz.dzieciol@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756244AbdCGWlH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:41:07 -0500
In-Reply-To: <1488463187-17365-1-git-send-email-tomasz.dzieciol@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <tomasz.dzieciol@nokia.com>
Date: Thu, 2 Mar 2017 14:59:47 +0100

> @@ -836,19 +843,30 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
>  	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
>  
>  	if (IN_DEV_ARP_ACCEPT(in_dev)) {
> -		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
> +		unsigned int addr_type = inet_addr_type_dev_table(net,
> +								  dev, sip);

Please don't mix coding style changes with real modifications.

> +	} else if (n) {
> +		unsigned int addr_type = inet_addr_type_dev_table(net,
> +								  dev, sip);

Thanks.
