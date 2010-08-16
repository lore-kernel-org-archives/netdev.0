From: Stephen Buck <stephen.buck@exinda.com>
Subject: Re: tproxy related crash in inet_hashtables
Date: Mon, 16 Aug 2010 18:26:58 +1000
Message-ID: <4C68F652.7070900@exinda.com>
References: <4C65432F.4030809@exinda.com>	<1281707736.4470.53.camel@edumazet-laptop>	<4C661D09.8030709@exinda.com> <20100814.221611.15248639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"hidden@sch.bme.hu" <hidden@sch.bme.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exhub015-3.exch015.msoutlookonline.net ([207.5.72.95]:46650
	"EHLO EXHUB015-3.exch015.msoutlookonline.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752925Ab0HPI2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 04:28:24 -0400
In-Reply-To: <20100814.221611.15248639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/08/10 15:16, David Miller wrote:
> From: Stephen Buck<stephen.buck@exinda.com>
> Date: Sat, 14 Aug 2010 14:35:21 +1000
>
>    
>> +		}
>> +		if (!node)
>> +			tb = inet_bind_bucket_create(table->bind_bucket_cachep,
>> +						     sock_net(sk), head, port);
>> +	}
>>   	sk_add_bind_node(child,&tb->owners);
>>      
> inet_bind_bucket_create() can fail due to memory allocation failure,
> you're therefore going to have to find a way to handle that.
>
> And in doing so you're going to find out that there is no easy
> way out of this code path in such an error, this code was
> absolutely not designed to be able to handle cases like this.
>    
You're right. I didn't cover the failure case. And no, it doesn't look easy.
I'll have another look at the problem when I get a chance.

Thanks for pointing it out.
