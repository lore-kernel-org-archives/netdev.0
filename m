From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] net: writes past the end of the struct
Date: Wed, 11 Jul 2012 01:27:45 -0700 (PDT)
Message-ID: <20120711.012745.2202204429130083377.davem@davemloft.net>
References: <20120711063214.GA11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab2GKI1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:27:46 -0400
In-Reply-To: <20120711063214.GA11812@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 11 Jul 2012 09:32:14 +0300

> There are a couple places that try to set part of the struct to 0 by
> doing:
> 
>     memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
> 
> It assumes that the first element is a dst_entry and the second element
> is ->rt6_table.  The problem is we changed the struct in 97cac0821a
> ('ipv6: Store route neighbour in rt6_info struct.') and we aren't
> clearing rt->n but instead we're writing past the end of the array.
> 
> I've changed it to:
>     memset(&rt->n, 0, sizeof(*rt) - offsetof(struct rt6_info, n));
> 
> The memset in ip6_dst_alloc() was ok but I changed it to use offsetof()
> as a cleanup.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Steffen Klassert had patches to do this more nicely, using "dst + 1"
as the pointer calculation, which therefore works no matter what
elements we add to struct rt6_info after the dst_entry.

I asked him to fix some things, he did too much casting, but he never
respun his patch set.  I definitely prefer this gets fixed his way.

http://patchwork.ozlabs.org/patch/169391/
http://patchwork.ozlabs.org/patch/169395/
