From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 1/2] udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
Date: Mon, 03 Nov 2008 11:46:38 +1000
Message-ID: <490E57FE.804@snapgear.com>
References: <490C1CA7.3070201@cn.fujitsu.com> <20081101.213529.60503932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:50037 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753930AbYKCBqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 20:46:42 -0500
In-Reply-To: <20081101.213529.60503932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Sat, 01 Nov 2008 17:08:55 +0800
> 
>> @@ -158,6 +159,8 @@ try_again:
>>  	else if (copied < ulen)
>>  		msg->msg_flags |= MSG_TRUNC;
>>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
>> +
>>  	/*
>>  	 * If checksum is needed at all, try to do it while copying the
>>  	 * data.  If the data is truncated, or if we only want a partial
>  ...
>>  	sock_recv_timestamp(msg, sk, skb);
>>  @@ -196,7 +204,7 @@ try_again:
>>  		sin6->sin6_flowinfo = 0;
>>  		sin6->sin6_scope_id = 0;
>>  -		if (skb->protocol == htons(ETH_P_IP))
>> +		if (is_udp4)
>>  			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
> 
> This patch is corrupted in ways I thought I would never see in my
> entire life.  Congratulations!

The patch looked okay to me, but judging by the bits you quoted,
the format=flowed is causing the problem.
