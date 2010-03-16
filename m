From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] BUG: unable to handle kernel NULL pointer dereference
 at br_multicast_leave_group
Date: Mon, 15 Mar 2010 20:38:33 -0700 (PDT)
Message-ID: <20100315.203833.165440357.davem@davemloft.net>
References: <4B9C49E7.1080703@fami-braun.de>
	<20100316031005.GA17727@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael-dev@fami-braun.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964992Ab0CPDiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 23:38:14 -0400
In-Reply-To: <20100316031005.GA17727@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 16 Mar 2010 11:10:05 +0800

> michael-dev@fami-braun.de wrote:
>> 
>> I'm currently using linux-next and have been running into an OOPs which
>> I think might be caused by a patch you submitted on 2010-02-27.
>> 
>> It's a linux-next kernel from 2010-03-12 on an x86 system and it
>> OOPs in the bridge module in br_mdp_ip_get (called by
>> br_multicast_leave_group) because the br->mdb is null.
> 
> Thanks, there's actually another spot (the query handler) where
> the same thing can happen.
> 
> Here's a patch to fix them both.
> 
> bridge: Move NULL mdb check into br_mdb_ip_get
> 
> Since all callers of br_mdb_ip_get need to check whether the
> hash table is NULL, this patch moves the check into the function.
> 
> This fixes the two callers (query/leave handler) that didn't
> check it.
> 
> Reported-by: Michael Braun <michael-dev@fami-braun.de>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
