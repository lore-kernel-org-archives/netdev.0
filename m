From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Thu, 16 Jan 2014 17:13:03 -0800 (PST)
Message-ID: <20140116.171303.2113967209121208034.davem@davemloft.net>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maze@google.com,
	cwang@twopensource.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaAQBNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:13:04 -0500
In-Reply-To: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 16:41:19 -0800

> This patch :
> 
> 1) Remove a dst leak if DST_NOCACHE was set on dst
>    Fix this by holding a reference only if dst really cached.

Can you explain this problem a little bit more?

Why do we have to handle DST_NOCACHE specially?  We hold a reference
and dst_release() knows what to do with DST_NOCACHE routes.

Or is it semantically undesirable for tunnels to cache these routes?
If so, why do we leave sockets caching DST_NOCACHE routes just fine?

Thanks.
