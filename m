From: wangweidong <wangweidong1@huawei.com>
Subject: Re: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Date: Tue, 19 Nov 2013 12:38:39 +0800
Message-ID: <528AEB4F.90605@huawei.com>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>	 <1384829247-8624-3-git-send-email-wangweidong1@huawei.com> <1384833303.8604.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <gerrit@erg.abdn.ac.uk>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<dccp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:5491 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab3KSEkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 23:40:25 -0500
In-Reply-To: <1384833303.8604.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/19 11:55, Eric Dumazet wrote:
> On Tue, 2013-11-19 at 10:47 +0800, Wang Weidong wrote:
>> commit efe4208f ("ipv6: make lookups simpler and faster") remove
>> the daddr and rcv_saddr from struct ipv6_pinfo. When use memcpy
>> the ipv6_pinfo, we lose the sk_v6_daddr and sk_v6_rcv_saddr, so
>> use the sk_v6_copy_addrs when needed.
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/dccp/ipv6.c     | 4 ++++
>>  net/ipv6/tcp_ipv6.c | 4 ++++
>>  net/sctp/ipv6.c     | 4 ++++
>>  3 files changed, 12 insertions(+)
>>
>> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
>> index 4ac71ff..90182a8 100644
>> --- a/net/dccp/ipv6.c
>> +++ b/net/dccp/ipv6.c
>> @@ -465,6 +465,10 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
>>  		newnp = inet6_sk(newsk);
>>  
>>  		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
>> +		/* Don't forget copy the rcv_saddr and daddr when
>> +		 * copy ipv6_pinfo.
>> +		 */
>> +		sk_v6_copy_addrs(newsk, sk);
>>  
>>  		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
>>  
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index 0740f93..83d011e 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -1116,6 +1116,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>>  		newtp = tcp_sk(newsk);
>>  
>>  		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
>> +		/* Don't forget copy the rcv_saddr and daddr when
>> +		 * copy ipv6_pinfo.
>> +		 */
>> +		sk_v6_copy_addrs(newsk, sk);
>>  
>>  		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
>>  
> 
> 
> No idea why this patch is needed for TCP.
> (btw you deal with v4mapped here, no mention of it in the changelog)
> 
> The fields were moved into generic socket, and generic socket is copied.
> 
> Are you seeing a real bug ?
> 
> Please elaborate, thanks !
> 

Hm, You are right. I am not careful to look over the generic socket whether it would be
copied. Sorry for that.
Thanks. 

> 
> 
> 
> 
