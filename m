From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: fix a signedness bug in cfpkt_iterate()
Date: Fri, 20 Feb 2015 17:35:26 -0500 (EST)
Message-ID: <20150220.173526.1527625915242269739.davem@davemloft.net>
References: <20150219091313.GA29358@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbbBTWf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:35:29 -0500
In-Reply-To: <20150219091313.GA29358@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 19 Feb 2015 12:13:13 +0300

> The cfpkt_iterate() function can return -EPROTO on error, but the
> function is a u16 so the negative value gets truncated to a positive
> unsigned short.  This causes a static checker warning.
> 
> The only caller which might care is cffrml_receive(), when it's checking
> the frame checksum.  I modified cffrml_receive() so that it never says
> -EPROTO is a valid checksum.
> 
> Also this isn't ever going to be inlined so I removed the "inline".
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
