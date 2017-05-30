From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Mon, 29 May 2017 23:31:09 -0400 (EDT)
Message-ID: <20170529.233109.702640863399503414.davem@davemloft.net>
References: <20170527151514.GA3347@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linyu.Yuan@alcatel-sbell.com.cn, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdE3DbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:31:11 -0400
In-Reply-To: <20170527151514.GA3347@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 27 May 2017 18:15:14 +0300

>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -148,17 +148,18 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> 
>>  	space -= data_len;
>> -	if (space > 0)
>> -		memset(opt, 0, space);
>> +
>> +	memset(opt, 0, space);
> 
> This can't be right.
> 
> And what size are you reducing?

It is right, space equals the same thing it would have equaled
before his changes, and a memset() of zero length will do the
right thing.

Finally, if space can be negative here, we have real problems.
