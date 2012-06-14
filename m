From: David Miller <davem@davemloft.net>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 03:00:21 -0700 (PDT)
Message-ID: <20120614.030021.2291563831943273331.davem@davemloft.net>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
	<1339665719.22704.692.camel@edumazet-glaptop>
	<1339667417.22704.707.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476Ab2FNKAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 06:00:24 -0400
In-Reply-To: <1339667417.22704.707.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Jun 2012 11:50:17 +0200

> On Thu, 2012-06-14 at 11:22 +0200, Eric Dumazet wrote:
> 
>> So you are saying that if you make skb_orphan_try() doing nothing, it
>> solves your problem ?
> 
> It probably does, if your application does an UDP flood, trying to send
> more than the link bandwidth. I guess only benchmarks workloads ever try
> to do that.

Eric, I just want to point out that back when this early orphaning
idea were being proposed I warned about this, and specifically I
mentioned that, for datagram sockets, the socket send buffer limits
are what provide proper rate control and fairness.

It also, therefore, protects the system from one datagram spammer
being able to essentially take over the network interface and blocking
out all other users.

Early orphaning breaks this completely.

I guess we decided that moving an atomic operation earlier is worth
all of this?

Now we are so addicted to the increased performance from early
orphaning that I fear we'll never be allowed back into that sane
state of affairs ever again.
