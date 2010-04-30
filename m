From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Fri, 30 Apr 2010 16:35:19 -0700 (PDT)
Message-ID: <20100430.163519.133415203.davem@davemloft.net>
References: <1272549408.4258.189.camel@bigi>
	<1272573383.3969.8.camel@bigi>
	<1272574909.2209.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com,
	bmb@athenacr.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759964Ab0D3XfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:35:14 -0400
In-Reply-To: <1272574909.2209.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Apr 2010 23:01:49 +0200

> [PATCH net-next-2.6] net: sock_def_readable() and friends RCU conversion

So what's the difference between call_rcu() freeing this little waitqueue
struct and doing it for the entire socket?

We'll still be doing an RCU call every socket destroy, and now we also have
a new memory allocation/free per connection.

This has to show up in things like 'lat_connect' and friends, does it not?
