From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] inet: Fixes for inet_csk_get_port and
 soreusport
Date: Sat, 17 Dec 2016 11:13:33 -0500 (EST)
Message-ID: <20161217.111333.1879745595587471743.davem@davemloft.net>
References: <20161215005416.1561632-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, jbacik@fb.com,
        eric.dumazet@gmail.com, raigatgoog@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752821AbcLQQNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:13:36 -0500
In-Reply-To: <20161215005416.1561632-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 14 Dec 2016 16:54:14 -0800

> This patch set fixes a couple of issues I noticed while debugging our
> softlockup issue in inet_csk_get_port.
> 
> - Don't allow jump into port scan in inet_csk_get_port if function
>   was called with non-zero port number (looking up explicit port
>   number).
> - When inet_csk_get_port is called with zero port number (ie. perform
>   scan) an reuseport is set on the socket, don't match sockets that
>   also have reuseport set. The intent from the user should be
>   to get a new port number and then explictly bind other
>   sockets to that number using soreuseport.
> 
> Tested:
> 
> Ran first patch on production workload with no ill effect.
> 
> For second patch, ran a little listener application and first
> demonstrated that unbound sockets with soreuseport can indeed
> be bound to unrelated soreuseport sockets.

Series applied, thanks Tom.
