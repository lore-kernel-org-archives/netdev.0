From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: tcp: move sk_rx_dst_set call after
 tcp_create_openreq_child()
Date: Mon, 20 Aug 2012 03:04:10 -0700 (PDT)
Message-ID: <20120820.030410.1083547560121610947.davem@davemloft.net>
References: <1345383038-8330-1-git-send-email-ncardwell@google.com>
	<1345383675.5158.202.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232Ab2HTKEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 06:04:11 -0400
In-Reply-To: <1345383675.5158.202.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 19 Aug 2012 15:41:15 +0200

> On Sun, 2012-08-19 at 09:30 -0400, Neal Cardwell wrote:
>> This commit removes the sk_rx_dst_set calls from
>> tcp_create_openreq_child(), because at that point the icsk_af_ops
>> field of ipv6_mapped TCP sockets has not been set to its proper final
>> value.
>> 
>> Instead, to make sure we get the right sk_rx_dst_set variant
>> appropriate for the address family of the new connection, we have
>> tcp_v{4,6}_syn_recv_sock() directly call the appropriate function
>> shortly after the call to tcp_create_openreq_child() returns.
>> 
>> This also moves inet6_sk_rx_dst_set() to avoid a forward declaration
>> with the new approach.
>> 
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Reported-by: Artem Savkov <artem.savkov@gmail.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/ipv4/tcp_ipv4.c      |    1 +
>>  net/ipv4/tcp_minisocks.c |    2 --
>>  net/ipv6/tcp_ipv6.c      |   25 +++++++++++++------------
>>  3 files changed, 14 insertions(+), 14 deletions(-)
> 
> Thanks Neal !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
