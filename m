From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: use new rhlist interface on sctp transport
 rhashtable
Date: Wed, 16 Nov 2016 23:22:36 -0500 (EST)
Message-ID: <20161116.232236.1426599744587048750.davem@davemloft.net>
References: <0a89ef8506db3bba6a37010bd5622cd145183ab4.1479223391.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, herbert@gondor.apana.org.au, phil@nwl.cc
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcKQEWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 23:22:38 -0500
In-Reply-To: <0a89ef8506db3bba6a37010bd5622cd145183ab4.1479223391.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 15 Nov 2016 23:23:11 +0800

> Now sctp transport rhashtable uses hash(lport, dport, daddr) as the key
> to hash a node to one chain. If in one host thousands of assocs connect
> to one server with the same lport and different laddrs (although it's
> not a normal case), all the transports would be hashed into the same
> chain.
> 
> It may cause to keep returning -EBUSY when inserting a new node, as the
> chain is too long and sctp inserts a transport node in a loop, which
> could even lead to system hangs there.
> 
> The new rhlist interface works for this case that there are many nodes
> with the same key in one chain. It puts them into a list then makes this
> list be as a node of the chain.
> 
> This patch is to replace rhashtable_ interface with rhltable_ interface.
> Since a chain would not be too long and it would not return -EBUSY with
> this fix when inserting a node, the reinsert loop is also removed here.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied to net-next, thanks.
