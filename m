From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 00:35:06 +0200
Message-ID: <4282889A.7080409@tpack.net>
References: <428284D6.9000804@tpack.net> <20050511222421.GA21331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050511222421.GA21331@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, May 12, 2005 at 12:19:02AM +0200, Tommy Christensen wrote:
> 
>>diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
>>--- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
>>+++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 00:11:08.990990172 +0200
>>@@ -785,11 +785,12 @@
>> 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
>> 		do_one_broadcast(sk, &info);
>> 
>>+	kfree_skb(skb);
>>+
>> 	netlink_unlock_table();
>> 
>> 	if (info.skb2)
>> 		kfree_skb(info.skb2);
>>-	kfree_skb(skb);
> 
> 
> Good catch.  But doesn't this affect skb2 as well?

No, skb2 cannot be shared with a listening socket. As I read the code,
it can only be non-null when delivery has failed.

-Tommy
