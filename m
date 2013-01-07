From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix NULL checking in devinet_ioctl()
Date: Sun, 06 Jan 2013 21:11:55 -0800 (PST)
Message-ID: <20130106.211155.961272945928036494.davem@davemloft.net>
References: <1357420764-12381-1-git-send-email-xi.wang@gmail.com>
	<1357427402.1678.4738.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xi.wang@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab3AGFL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:11:56 -0500
In-Reply-To: <1357427402.1678.4738.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Jan 2013 15:10:02 -0800

> On Sat, 2013-01-05 at 16:19 -0500, Xi Wang wrote:
>> The NULL pointer check `!ifa' should come before its first use.
>> 
>> Signed-off-by: Xi Wang <xi.wang@gmail.com>
>> ---
>>  net/ipv4/devinet.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index cc06a47..a8e4f26 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -823,9 +823,9 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>>  		if (!ifa) {
>>  			ret = -ENOBUFS;
>>  			ifa = inet_alloc_ifa();
>> -			INIT_HLIST_NODE(&ifa->hash);
>>  			if (!ifa)
>>  				break;
>> +			INIT_HLIST_NODE(&ifa->hash);
>>  			if (colon)
>>  				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
>>  			else
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Bug origin : commit fd23c3b31107e2fc483301ee923d8a1db14e53f4
> (ipv4: Add hash table of interface addresses) 
> 
> in linux-2.6.39

Applied and queued up for -stable, thanks.
