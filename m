From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix incorrect initializer in union
 vxlan_addr
Date: Mon, 18 Aug 2014 10:11:43 -0700 (PDT)
Message-ID: <20140818.101143.2274310300741627370.davem@davemloft.net>
References: <53EDCC19.70702@linux.vnet.ibm.com>
	<53EDCCFE.5090301@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gstenzel@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaHRRL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 13:11:27 -0400
In-Reply-To: <53EDCCFE.5090301@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Date: Fri, 15 Aug 2014 11:03:58 +0200

> 
> The first initializer in the following
> 
> 		union vxlan_addr ipa = {
> 			.sin.sin_addr.s_addr = tip,
> 			.sa.sa_family = AF_INET,
> 		};
> 
> is optimised away by the compiler, due to the second initializer,
> therefore initialising .sin.sin_addr.s_addr always to 0.
> This results in netlink messages indicating a L3 miss never contain
> the
> missed IP address. This was observed with GCC 4.8 and 4.9. I do not
> know about previous versions.
> The problem affects user space programs relying on an IP address being
> sent as part of a netlink message indicating a L3 miss.
> 
> Changing
> 			.sa.sa_family = AF_INET,
> to
> 			.sin.sin_family = AF_INET,
> fixes the problem.
> 
>     Signed-off-by: Gerhard Stenzel <gerhard.stenzel@de.ibm.com>

Your patch was corrupted by your email client, also please do not
indent your signoff.

THanks.
