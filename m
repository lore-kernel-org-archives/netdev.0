From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: fix TOS value in ACK messages sent
 from TIME_WAIT
Date: Mon, 24 Oct 2011 03:06:32 -0400 (EDT)
Message-ID: <20111024.030632.1448353383063978213.davem@davemloft.net>
References: <CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
	<1318393869.3686.26.camel@edumazet-laptop>
	<1319192965.2338.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, muralira@google.com, ak@linux.intel.com,
	hidden@balabit.hu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab1JXHGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 03:06:40 -0400
In-Reply-To: <1319192965.2338.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2011 12:29:25 +0200

> There is a long standing bug in linux tcp stack, about ACK messages sent
> on behalf of TIME_WAIT sockets.
> 
> In the IP header of the ACK message, we choose to reflect TOS field of
> incoming message, and this might break some setups.
> 
> Example of things that were broken :
>   - Routing using TOS as a selector
>   - Firewalls
>   - Trafic classification / shaping
> 
> We now remember in timewait structure the inet tos field and use it in
> ACK generation, and route lookup.
> 
> Notes :
>  - We still reflect incoming TOS in RST messages.
>  - We could extend MuraliRaja Muniraju patch to report TOS value in
> netlink messages for TIME_WAIT sockets.
>  - A patch is needed for IPv6
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
