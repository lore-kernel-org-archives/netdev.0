From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: 2-clause nla_ok()
Date: Sat, 03 Dec 2016 15:54:25 -0500 (EST)
Message-ID: <20161203.155425.1659260672294542181.davem@davemloft.net>
References: <20161202005906.GA31170@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750906AbcLCUya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:54:30 -0500
In-Reply-To: <20161202005906.GA31170@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 2 Dec 2016 03:59:06 +0300

> nla_ok() consists of 3 clauses:
> 
> 	1) int rem >= (int)sizeof(struct nlattr)
> 
> 	2) u16 nla_len >= sizeof(struct nlattr)
> 
> 	3) u16 nla_len <= int rem
> 
> The statement is that clause (1) is redundant.
> 
> What it does is ensuring that "rem" is a positive number,
> so that in clause (3) positive number will be compared to positive number
> with no problems.
> 
> However, "u16" fully fits into "int" and integers do not change value
> when upcasting even to signed type. Negative integers will be rejected
> by clause (3) just fine. Small positive integers will be rejected
> by transitivity of comparison operator.
> 
> NOTE: all of the above DOES NOT apply to nlmsg_ok() where ->nlmsg_len is
> u32(!), so 3 clauses AND A CAST TO INT are necessary.
> 
> Obligatory space savings report: -1.6 KB
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks fine, applied to net-next, thanks.
