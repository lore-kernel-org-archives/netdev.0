From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] inetpeer: fix a race in inetpeer_gc_worker()
Date: Wed, 06 Jun 2012 10:45:07 -0700 (PDT)
Message-ID: <20120606.104507.159660237145135640.davem@davemloft.net>
References: <1338901218.2760.2615.camel@edumazet-glaptop>
	<20120605130953.GG27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181Ab2FFRpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:45:08 -0400
In-Reply-To: <20120605130953.GG27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 5 Jun 2012 15:09:54 +0200

> On Tue, Jun 05, 2012 at 03:00:18PM +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
>> the routing cache) added a race :
>> 
>> Before freeing an inetpeer, we must respect a RCU grace period, and make
>> sure no user will attempt to increase refcnt.
>> 
>> inetpeer_invalidate_tree() waits for a RCU grace period before inserting
>> inetpeer tree into gc_list and waking the worker. At that time, no
>> concurrent lookup can find a inetpeer in this tree.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

I'll apply this and queue it up for -stable, thanks.
