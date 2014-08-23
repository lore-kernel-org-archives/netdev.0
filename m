From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] vxlan: fix incorrect initializer in union
 vxlan_addr
Date: Fri, 22 Aug 2014 19:55:35 -0700 (PDT)
Message-ID: <20140822.195535.1578874146066452604.davem@davemloft.net>
References: <53F79B38.8070806@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gstenzel@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHWCzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:55:36 -0400
In-Reply-To: <53F79B38.8070806@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Date: Fri, 22 Aug 2014 21:34:16 +0200

> The first initializer in the following
> 
>         union vxlan_addr ipa = {
>             .sin.sin_addr.s_addr = tip,
>             .sa.sa_family = AF_INET,
>         };
> 
> is optimised away by the compiler, due to the second initializer,
> therefore initialising .sin.sin_addr.s_addr always to 0.
> This results in netlink messages indicating a L3 miss never contain the
> missed IP address. This was observed with GCC 4.8 and 4.9. I do not know about previous versions.
> The problem affects user space programs relying on an IP address being
> sent as part of a netlink message indicating a L3 miss.
> 
> Changing
>             .sa.sa_family = AF_INET,
> to
>             .sin.sin_family = AF_INET,
> fixes the problem.
> 
> Signed-off-by: Gerhard Stenzel <gerhard.stenzel@de.ibm.com>

Applied and queued up for -stable, thanks.
