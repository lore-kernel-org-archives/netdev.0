From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] hash: Introduce ptr_hash_mix routine
Date: Tue, 07 Aug 2012 14:39:33 -0700 (PDT)
Message-ID: <20120807.143933.556038665324374825.davem@davemloft.net>
References: <501FD11B.6000006@parallels.com>
	<20120806.134459.954167716448843820.davem@davemloft.net>
	<5020DBCD.7040806@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab2HGVjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 17:39:35 -0400
In-Reply-To: <5020DBCD.7040806@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 07 Aug 2012 13:11:41 +0400

> Maybe it would be better to change the way neigh_table->hash work more
> significantly then? Currently it is used like
> 
> 	hash = tbl->hash(key, dev, tbl->rnd);
> 	hash >>= (32 - tbl->hash_shift);
> 
> i.e. the caller asks for u32 hash value and then trims some lower bits.

We do this because the hash function we use in the neigh
implementations causes the top bits to have the most entropy.

Please look at the commits that made the code this way, it's
very much intentional.
