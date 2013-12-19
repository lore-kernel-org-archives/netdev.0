From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Thu, 19 Dec 2013 15:47:32 +0800
Message-ID: <52B2A494.5080702@windriver.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>		 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>		 <52B24D7D.6060902@windriver.com>	 <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>	 <52B26553.9070103@windriver.com> <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?546L6IGq?= <xiyou.wangcong@gmail.com>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46813 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3LSHr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 02:47:27 -0500
In-Reply-To: <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8819=E6=97=A5 11:44, Eric Dumazet wrote:
> On Thu, 2013-12-19 at 11:17 +0800, Fan Du wrote:
>>
>
>> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
>> index 1006a26..22f4f90 100644
>> --- a/include/net/netns/xfrm.h
>> +++ b/include/net/netns/xfrm.h
>> @@ -58,9 +58,9 @@ struct netns_xfrm {
>>    	struct dst_ops		xfrm6_dst_ops;
>>    #endif
>>    	spinlock_t xfrm_state_lock;
>> -	spinlock_t xfrm_policy_sk_bundle_lock;
>>    	rwlock_t xfrm_policy_lock;
>>    	struct mutex xfrm_cfg_mutex;
>> +	struct llist_head xp_sk_bundles_list;
>>    };
>>
>>    #endif
>> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
>> index 59f5d0a..05296ab 100644
>> --- a/include/net/xfrm.h
>> +++ b/include/net/xfrm.h
>> @@ -957,6 +957,7 @@ struct xfrm_dst {
>>    	u32 child_mtu_cached;
>>    	u32 route_cookie;
>>    	u32 path_cookie;
>> +	struct llist_node       xdst_llist;
>>    };
>>
>
> Hmm... Thats not very nice.
>
> Please reuse the storage adding a llist_node in the union ?
>
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 44995c13e941..3f604f47cc58 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -14,6 +14,7 @@
>   #include<linux/rcupdate.h>
>   #include<linux/bug.h>
>   #include<linux/jiffies.h>
> +#include<linux/llist.h>
>   #include<net/neighbour.h>
>   #include<asm/processor.h>
>
> @@ -103,6 +104,7 @@ struct dst_entry {
>   		struct rtable __rcu	*rt_next;
>   		struct rt6_info		*rt6_next;
>   		struct dn_route __rcu	*dn_next;

Add dst_entry with llist into a global llist head, after this
does the dst internal usage of above member corrupt below llist
if we unionize them together here?

> +		struct llist_node	llist;
>   	};
>   };



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
