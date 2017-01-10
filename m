From: David Miller <davem@davemloft.net>
Subject: Re: using rcu_read_lock() after calling dst_neigh_lookup
Date: Tue, 10 Jan 2017 12:02:13 -0500 (EST)
Message-ID: <20170110.120213.1297610016130641176.davem@davemloft.net>
References: <ead29087-05cc-c586-3b7e-d37c2e6f753c@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, idosch@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762607AbdAJRCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:02:18 -0500
In-Reply-To: <ead29087-05cc-c586-3b7e-d37c2e6f753c@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Tue, 10 Jan 2017 16:22:51 +0200

> While the documentation in neighbour.c says:
> 
>  "Neighbour entries are protected:
>    - with reference count.
>    - with rwlock neigh->lock
>    Reference count prevents destruction.
>    neigh->lock mainly serializes ll address data and its validity state."
> 
> So what is the right way to protect the neigh entry parameters? I
> couldn't find why rcu_read_lock() is helping here (dst_neigh_lookup
> already takes a reference on the neigh).

Documentation is, unfortunately, out of date.

When there is a mis-match, usually the behavior of the code in the
tree trumps whatever the documentation says.
