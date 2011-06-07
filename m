From: Reinhard Max <max@suse.de>
Subject: Re: [PATCH] net/ipv6: check for mistakenly passed in non-AF_INET6
 sockaddrs
Date: Tue, 7 Jun 2011 09:25:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106070910410.10360@nitsch.suse.de>
References: <20110525155918.GA27869@suse.de> <20110601.210359.2079286191194442010.davem@davemloft.net> <alpine.LNX.2.00.1106061538210.13876@nitsch.suse.de> <20110606160007.GD28535@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Marcus Meissner <meissner@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40717 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab1FGHZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 03:25:04 -0400
In-Reply-To: <20110606160007.GD28535@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Jun 2011 at 18:00, Marcus Meissner wrote:

> Same check as for IPv4, also do for IPv6.
> [...]
> +
> +	if (addr->sin6_family != AF_INET6)
> +		return -EINVAL;
> +

According to the POSIX manpage for bind(), the error code should be 
EAFNOSUPPORT ("The specified address is not a valid address for the 
address family of the specified socket"). This would also match the 
error code of connect() in the same situation.

And I think the family should be checked before the length for both, 
bind() and connect(), to get more descriptive error messages when 
passing an address of the wrong family.


cu
 	Reinhard
