From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 23 Sep 2004 17:40:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4152EE68.4030803@eurodev.net>
References: <414DF11C.1080505@eurodev.net>	<20040919215915.GB9573@gondor.apana.org.au>	<1095633569.1047.107.camel@jzny.localdomain>	<20040919231734.GA10124@gondor.apana.org.au>	<1095647944.1046.206.camel@jzny.localdomain>	<20040920025802.GA11567@gondor.apana.org.au>	<1095683660.1047.254.camel@jzny.localdomain>	<414F1E12.6010808@eurodev.net>	<20040922000503.GA13218@gondor.apana.org.au>	<4150E7E5.2000001@eurodev.net>	<20040922045239.GA19573@gondor.apana.org.au>	<1095854920.1047.64.camel@jzny.localdomain> <20040922105221.59a67d4b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040922105221.59a67d4b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>On 22 Sep 2004 08:08:40 -0400
>jamal <hadi@cyberus.ca> wrote:
>
>  
>
>>Note also, theres a lot of wastage of that scarce sock buffer via page
>>sized skbs - its not as trivial to fix, but would go some way to improve
>>overrunning of the socket.
>>    
>>
>
>Thanks for reminding me about this.
>  
>

Initially we could allocate a skb with size NLMSG_GOODSIZE, then after 
all the information has been added, we could use a function (skb_*) 
which allocates a new buffer headroom, memcpy the old skb headroom and 
release it, so we trim the useless part of the headroom. This make us 
waste some extra jiffies with memcpy's but we could save same space in 
the queue. Does such skb_* function exist?

Another choice could be using a temporary buffer and them memcpy the 
buffer to a skb which has only allocated the buffer space used.

regards,
Pablo
