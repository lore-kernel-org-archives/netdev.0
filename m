From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] SOCK: add raw6 drops counter
Date: Wed, 14 Nov 2007 14:45:33 +0800
Message-ID: <473A998D.8050101@cn.fujitsu.com>
References: <47397514.2070002@cn.fujitsu.com> <473A6792.10405@cn.fujitsu.com> <473A686D.9020200@cn.fujitsu.com> <473A8C2B.2040709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:62200 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760970AbXKNGrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 01:47:40 -0500
In-Reply-To: <473A8C2B.2040709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet said the following on 2007-11-14 13:48:
>> diff -Nurp linux-2.6.24-rc2.org/net/ipv6/raw.c
>> linux-2.6.24-rc2/net/ipv6/raw.c
>> --- linux-2.6.24-rc2.org/net/ipv6/raw.c    2007-11-09
>> 16:38:05.000000000 +0800
>> +++ linux-2.6.24-rc2/net/ipv6/raw.c    2007-11-14 09:46:54.000000000
>> +0800
>> @@ -354,14 +354,14 @@ static inline int rawv6_rcv_skb(struct s
>>  {
>>      if ((raw6_sk(sk)->checksum || sk->sk_filter) &&
>>          skb_checksum_complete(skb)) {
>> -        /* FIXME: increment a raw6 drops counter here */
>> +        atomic_inc(&sk->sk_drops);   
> 
> I am not sure the comment was refering to a per socket counter here.
> 
> If the frame checksum is bad, we can not be sure the socket is OK, since
> the garbaged bits could be in the tuple that identify the socket.
> 
> Maybe here we want to increment a global raw6 drop counter (well, for
> the given ipv6 instance)
> 

What the /proc/net/raw6 shows is statistical information about raw socket
in IPv6 stack. And the information is per socket per row. 
So I think it's better to count it to per socket.

