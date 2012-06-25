From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tcp: heed result of security_inet_conn_request()
 in tcp_v6_conn_request()
Date: Mon, 25 Jun 2012 16:05:32 -0700 (PDT)
Message-ID: <20120625.160532.11456533643470796.davem@davemloft.net>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
	<1340523417.23933.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2FYXFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:05:33 -0400
In-Reply-To: <1340523417.23933.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 24 Jun 2012 09:36:57 +0200

> On Sun, 2012-06-24 at 01:22 -0400, Neal Cardwell wrote:
>> If security_inet_conn_request() returns non-zero then TCP/IPv6 should
>> drop the request, just as in TCP/IPv4 and DCCP in both IPv4 and IPv6.
>> 
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> ---
>>  net/ipv6/tcp_ipv6.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index 3a9aec2..9df64a5 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -1212,7 +1212,8 @@ have_isn:
>>  	tcp_rsk(req)->snt_isn = isn;
>>  	tcp_rsk(req)->snt_synack = tcp_time_stamp;
>>  
>> -	security_inet_conn_request(sk, skb, req);
>> +	if (security_inet_conn_request(sk, skb, req))
>> +		goto drop_and_release;
>>  
>>  	if (tcp_v6_send_synack(sk, req,
>>  			       (struct request_values *)&tmp_ext,
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied to 'net'.
