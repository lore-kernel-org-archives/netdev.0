From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 15:54:24 -0500 (EST)
Message-ID: <20170117.155424.1815351091063210993.davem@davemloft.net>
References: <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
        <20170117.153846.1832359427601278475.davem@davemloft.net>
        <7655b85f-4c03-7f08-315c-b6a99a1631f0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdAQVBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 16:01:11 -0500
In-Reply-To: <7655b85f-4c03-7f08-315c-b6a99a1631f0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 17 Jan 2017 13:46:22 -0700

> In short seems like removing the dev + the current patch dropping
> the lock fixes the current deadlock problem and should be fine.

What about the state recorded by fib_get_nhs() and similar?  There is
a mapping from ifindex to ->nh_dev which would be invalidated if the
RTNL semaphore is dropped.

It won't get updated by device events, which is what normally happens,
because the fib_info is not in any of the fib_trie tables yet.

So I think you still have a huge problem without doing proper restarts.
