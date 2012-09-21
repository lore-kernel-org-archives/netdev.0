From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 13:56:01 -0400 (EDT)
Message-ID: <20120921.135601.254379488076661898.davem@davemloft.net>
References: <20120921085502.4534.20232.stgit@dragon>
	<1348241111.2669.580.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab2IUR4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:56:03 -0400
In-Reply-To: <1348241111.2669.580.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Sep 2012 17:25:11 +0200

> On Fri, 2012-09-21 at 10:55 +0200, Jesper Dangaard Brouer wrote:
>> Make it possible to adjust the TCP default initial advertised receive
>> window, via sysctl /proc/sys/net/ipv4/tcp_init_recv_window.
>> 
>> The window size is this value multiplied by the MSS of the connection.
>> The default value is (still) 10, as descibed in commit 356f039822b
>> (TCP: increase default initial receive window.)
>> 
>> Allow minimum value of 1, but recommend against setting value below 2
>> in the documentation.
>> 
>> Its possible to control/override this value per route table entry via
>> the iproute2 option initrwnd.  Having the global default exported via
>> sysctl, helps determine the default setting, and make is easier to
>> adjust.
> 
> I was wondering why its not symmetric :
> 
> If we add a sysctl for initial receive window, we need another one for
> initial send window ?

Unlike the routing configuration, this is susceptible to serious abuse.

All it takes is for one jackass vendor to say that this should be set
to 1,000 in in sysctl.conf when using their product.

Whereas setting it on a per-route basis forces the person doing it
to actually consider that there might be ramifications that have to
do with the paths on which you are making this adjustment.

I would only let this in if you hard limited the setting to it's
current setting, 10.  So people could decrease it.
