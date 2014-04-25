From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Fri, 25 Apr 2014 12:51:55 -0400 (EDT)
Message-ID: <20140425.125155.861435686727308330.davem@davemloft.net>
References: <1398424172-17530-1-git-send-email-lorenzo@google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	eric.dumazet@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaDYQv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 12:51:57 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 25 Apr 2014 11:24:21 +0000

> From: Lorenzo Colitti
>> rawv6_sendmsg and udpv6_sendmsg have ~100 lines of almost
>> identical code. Move this into a new ipv6_datagram_send_common
>> helper function.
>> 
>> Tested: black-box tested using user-mode Linux.
>> 
>> - Basic UDP sends using sendto work.
>> - Mark routing and oif routing using SO_BINDTODEVICE work.
> ...
>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> index d640925..f1a247a 100644
>> --- a/include/net/ipv6.h
>> +++ b/include/net/ipv6.h
>> @@ -785,6 +785,13 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
>>  int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
>>  int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
>>  				 int addr_len);
>> +int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
>> +			     struct sockaddr_in6 *sin6, int addr_len,
>> +			     struct flowi6 *fl6, struct dst_entry **dstp,
>> +			     struct ipv6_txoptions **optp,
>> +			     struct ipv6_txoptions *opt_space,
>> +			     int *hlimit, int *tclass, int *dontfrag,
>> +			     int *connected);
> 
> That is a lot of parameters! and udp send is probably an important path.

The more I read this series the more I dislike it.

All of these pointers being passed in, were local variables in the
original code.

This consolidation makes the code much worse, not better.
