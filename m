From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH, take2] netfilter : struct xt_table_info diet
Date: Tue, 20 Nov 2007 08:50:15 +0100
Message-ID: <474291B7.6060602@trash.net>
References: <E1IuN87-0003r5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, dada1@cosmosbay.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759614AbXKTHuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:50:20 -0500
In-Reply-To: <E1IuN87-0003r5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Simon Horman <horms@verge.net.au> wrote:
>   
>> @@ -269,9 +269,12 @@ struct xt_table_info
>>        unsigned int underflow[NF_INET_NUMHOOKS];
>>
>>        /* ipt_entry tables: one per CPU */
>> -       char *entries[NR_CPUS];
>> +       /* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
>> +       char *entries[1];
>>     
>
> Just do
>
> 	char *entries[];
>
> Not only is it ISO C99, but the compiler will die if it's not at
> the end.
>
> Actually I haven't read the rest of the patch, so scratch this
> comment if you really need to have one entry there for some reason :)
>   

I thought this too, but its needed for the bootstrap tables, which are
declared on the stack :)
