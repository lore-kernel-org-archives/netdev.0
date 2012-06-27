From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 10:45:10 +0200
Message-ID: <1340786710.26242.37.camel@edumazet-glaptop>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <1340781845.2028.133.camel@localhost>
	 <1340782216.10893.427.camel@edumazet-glaptop>
	 <1340783670.2028.141.camel@localhost>
	 <1340784137.26242.5.camel@edumazet-glaptop>
	 <1340785275.2028.151.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62096 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab2F0IpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:45:17 -0400
Received: by eeit10 with SMTP id t10so239963eei.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 01:45:16 -0700 (PDT)
In-Reply-To: <1340785275.2028.151.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 10:21 +0200, Jesper Dangaard Brouer wrote:

> It works because we have a spinlock problem in the code... Perhaps, they
> did it, because we have have locking/contention problem, not the other
> way around ;-)  How about fixing the code instead? ;-)))

The socket lock is currently mandatory.

It's really _hard_ to remove it, your attempts added a lot of races.

I want to do it properly, adding needed RCU and array of spinlocks were
appropriate.

Hopefully, its easier than the RCU conversion I did for the lookups of
ESTABLISHED/TIMEWAIT sockets.
