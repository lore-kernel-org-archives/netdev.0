From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Tue, 02 Apr 2013 12:12:23 -0400 (EDT)
Message-ID: <20130402.121223.496337697838525487.davem@davemloft.net>
References: <1364917500.5113.176.camel@edumazet-glaptop>
	<20130402155822.GB29115@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760999Ab3DBQMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 12:12:24 -0400
In-Reply-To: <20130402155822.GB29115@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 2 Apr 2013 17:58:22 +0200

> On Tue, Apr 02, 2013 at 08:45:00AM -0700, Eric Dumazet wrote:
>>From: Eric Dumazet <edumazet@google.com>
>>
>>commit 00cfec37484761 (net: add a synchronize_net() in
>>netdev_rx_handler_unregister())
>>allows us to remove the synchronized_net() call from del_nbp()
>>
>>Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Veaceslav Falico <vfalico@redhat.com>

Applied.

Note that we have a few spots now that do two synchronize_net()'s per
opertaion, such as team port removal, and openvswitch has such a path
as well.  They all are of the form:

	netdev_rx_handler_unregister()
	...
	lots of other stuff
	...
	synchronize_net();

So might be harder to factor back out than this br_if.c case.
