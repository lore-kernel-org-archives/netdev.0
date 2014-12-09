From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: allow setting congctl via routing
 table
Date: Tue, 09 Dec 2014 15:58:44 -0500 (EST)
Message-ID: <20141209.155844.1175199719902606020.davem@davemloft.net>
References: <1417909163-19135-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbaLIU6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:58:47 -0500
In-Reply-To: <1417909163-19135-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun,  7 Dec 2014 00:39:19 +0100

> This is the second part of our work and allows for setting the congestion
> control algorithm via routing table. For details, please see individual
> patches.
> 
> Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.
> 
> Patch for iproute2: http://patchwork.ozlabs.org/patch/418149/
> 
> Thanks!
> 
> v1->v2:
>  - Very sorry, I noticed I had decnet disabled during testing.
>    Added missing header include in decnet, rest as is.

I don't like how you have to explicitly load the congestion control
module before asking for it to be used in the route entry metric.

It should request the module automatically just like the stack already
does for other cases.

You have run into this problem as a result of your design decision to
use that 32-bit key.  Therefore, I think you seriously need to
reconsider that aspect of your change.
