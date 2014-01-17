From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Thu, 16 Jan 2014 17:40:14 -0800 (PST)
Message-ID: <20140116.174014.415638698308506562.davem@davemloft.net>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140116.171303.2113967209121208034.davem@davemloft.net>
	<1389922350.31367.447.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maze@google.com,
	cwang@twopensource.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaAQBkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:40:15 -0500
In-Reply-To: <1389922350.31367.447.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 17:32:30 -0800

> On Thu, 2014-01-16 at 17:13 -0800, David Miller wrote:
> 
>> Why do we have to handle DST_NOCACHE specially?  We hold a reference
>> and dst_release() knows what to do with DST_NOCACHE routes.
>> 
>> Or is it semantically undesirable for tunnels to cache these routes?
>> If so, why do we leave sockets caching DST_NOCACHE routes just fine?
> 
> If DST_NOCACHE is set on a dst, this dst cannot be used by rcu users,
> because dst_release() will immediately free the dst, without rcu grace
> period.

Ok, if we ever start using DST_NOCACHE in ipv6 we will have to modify
ipv6 tunnels as they cache similarly.
