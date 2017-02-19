From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: check duplicate node before inserting a new
 transport
Date: Sun, 19 Feb 2017 18:19:49 -0500 (EST)
Message-ID: <20170219.181949.2029549204792959633.davem@davemloft.net>
References: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdBSXT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:19:56 -0500
In-Reply-To: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 17 Feb 2017 16:35:24 +0800

> sctp has changed to use rhlist for transport rhashtable since commit
> 7fda702f9315 ("sctp: use new rhlist interface on sctp transport
> rhashtable").
> 
> But rhltable_insert_key doesn't check the duplicate node when inserting
> a node, unlike rhashtable_lookup_insert_key. It may cause duplicate
> assoc/transport in rhashtable. like:
> 
>  client (addr A, B)                 server (addr X, Y)
>     connect to X           INIT (1)
>                         ------------>
>     connect to Y           INIT (2)
>                         ------------>
>                          INIT_ACK (1)
>                         <------------
>                          INIT_ACK (2)
>                         <------------
> 
> After sending INIT (2), one transport will be created and hashed into
> rhashtable. But when receiving INIT_ACK (1) and processing the address
> params, another transport will be created and hashed into rhashtable
> with the same addr Y and EP as the last transport. This will confuse
> the assoc/transport's lookup.
> 
> This patch is to fix it by returning err if any duplicate node exists
> before inserting it.
> 
> Fixes: 7fda702f9315 ("sctp: use new rhlist interface on sctp transport rhashtable")
> Reported-by: Fabio M. Di Nitto <fdinitto@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
