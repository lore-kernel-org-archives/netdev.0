From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: don't add link local route when there is no
 link local address
Date: Tue, 02 Oct 2012 22:38:41 -0400 (EDT)
Message-ID: <20121002.223841.1202289353286506341.davem@davemloft.net>
References: <20121001.165527.1025640918619977740.davem@davemloft.net>
	<1349169554-3774-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab2JCCin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:38:43 -0400
In-Reply-To: <1349169554-3774-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  2 Oct 2012 11:19:14 +0200

> When an address is added on loopback (ip -6 a a 2002::1/128 dev lo), a route
> to fe80::/64 is added in the main table:
>   unreachable fe80::/64 dev lo  proto kernel  metric 256  error -101
> 
> This route does not match any prefix (no fe80:: address on lo). In fact,
> addrconf_dev_config() will not add link local address because this function
> filters interfaces by type. If the link local address is added manually, the
> route to the link local prefix will be automatically added by
> addrconf_add_linklocal().
> Note also, that this route is not deleted when the address is removed.
> 
> After looking at the code, it seems that addrconf_add_lroute() is redundant with
> addrconf_add_linklocal(), because this function will add the link local route
> when the link local address is configured.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
