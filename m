From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Ipvlan should return an error when an address is
 already in use.
Date: Sun, 01 Jan 2017 22:26:32 -0500 (EST)
Message-ID: <20170101.222632.843875843588487678.davem@davemloft.net>
References: <20161231041058.GC2448@templeofstupid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org
To: kjlx@templeofstupid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755232AbdABD0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 22:26:34 -0500
In-Reply-To: <20161231041058.GC2448@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krister Johansen <kjlx@templeofstupid.com>
Date: Fri, 30 Dec 2016 20:10:58 -0800

> The ipvlan code already knows how to detect when a duplicate address is
> about to be assigned to an ipvlan device.  However, that failure is not
> propogated outward and leads to a silent failure.  This teaches the ip
> address addition functions how to report this error to the user
> applications so that a notifier chain failure during ip address addition
> will not appear to succeed when it actually has not.
> 
> This can be especially useful if it is necessary to provision many
> ipvlans in containers.  The provisioning software (or operator) can use
> this to detect situations where an ip address is unexpectedly in use.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>

Your patch isn't handling the case of primary address promotions,
which also issue NETDEV_UP events on these notifier chains.

But on a more basic level, it's extremely important that once you
start using the notifier_{from,to}_errno() handling for a notifier,
you must start doing so for all such cases of that notifier.
