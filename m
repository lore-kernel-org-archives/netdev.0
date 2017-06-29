From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rocker: move dereference before free
Date: Thu, 29 Jun 2017 14:19:47 -0400 (EDT)
Message-ID: <20170629.141947.1907909639870266602.davem@davemloft.net>
References: <20170628114421.qyv6lmugpbjqntpt@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, arnd@arndb.de, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbdF2STu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:19:50 -0400
In-Reply-To: <20170628114421.qyv6lmugpbjqntpt@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 28 Jun 2017 14:44:21 +0300

> My static checker complains that ofdpa_neigh_del() can sometimes free
> "found".   It just makes sense to use it first before deleting it.
> 
> Fixes: ecf244f753e0 ("rocker: fix maybe-uninitialized warning")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.

> Most ref counting function use atomic_dec() but ofdpa_neigh_del() just
> uses normal decrement.  Are you sure this isn't racy?

A spinlock is held always when this counter is touched.
