From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [15/*] [INET] Fix IPsec calculation in ip_append_data/ip6_append_data
Date: Mon, 21 Mar 2005 18:14:07 +0200
Message-ID: <423EF2CF.7020403@kolumbus.fi>
References: <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050316113149.GA10960@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050316113149.GA10960@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Hi Dave:
>
>On Tue, Mar 15, 2005 at 08:19:04PM +1100, herbert wrote:
>  
>
>>This patch fixes the IPsec overhead handling in ip_append_data and
>>ip6_append_data.  As it is they assume that the IPsec overhead is
>>constant.  This is not true as with ESP the IPsec overhead will vary
>>as the MTU varies.
>>    
>>
>
>This patch is wrong.  This is the *one* place where we do need to
>use the path MTU.  The reason is that when the packet is fragmented
>we only pay for the IPsec overhead once over all and not once for
>each fragment.
>
>Please revert it for now.
>
>The trailer_len in ip_append_data is not quite right as the trailer's
>length depends on the length of the entire packet.  However, it should
>be harmless since ESP knows how to extend the packet when necessary.
>
>Thanks,
>  
>
Shouldn't ip_output also use the path variant, dst_mtu(skb->dst->path), 
it's surely after ipsec- processing?

--Mika
