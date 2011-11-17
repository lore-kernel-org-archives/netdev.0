From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Thu, 17 Nov 2011 16:53:09 -0500 (EST)
Message-ID: <20111117.165309.1283667903570988053.davem@davemloft.net>
References: <20111116.170213.1763930566851730338.davem@davemloft.net>
	<20111116211738.067354c0@asterix.rh>
	<20111116234042.6ad8d723@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab1KQVxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:53:11 -0500
In-Reply-To: <20111116234042.6ad8d723@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 16 Nov 2011 23:40:42 -0200

> To make sure we are in the same page, this simple setup reproduces
> the issue.
> 
> IP: 10.0.0.1
> gw: 10.0.0.100
> +--------+          +-----+ primary: 10.0.0.2
> | client |----+-----| GW1 |   alias: 10.0.0.100
> +--------+    |     +-----+      gw: 10.0.0.254
>            +--+--+
>            | GW2 |---> internet
>            +-----+
>          10.0.0.254
> 
> 1. Client sends TCP SYN to an internet host using
>    GW1 alias address as default gw address
> 
> 2. Then GW1 sends the ICMP redirect back to client
>    using the primary address as source address.
> 
> 3. GW1 forwards the original packet to GW2
> 
> 4. client ignores the ICMP redirect because
>    client.gw != gw1.primary.

GW1 must respond using a source address matching 'alias', ie.
10.0.0.100 and I would accept a mechinsm to make sure that happens,
if not by default then via a sysctl or similar control.
