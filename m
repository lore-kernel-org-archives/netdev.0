From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from	untrusted
 sources
Date: Tue, 09 Jun 2009 22:51:23 -0700
Message-ID: <4A2F49DB.20207@us.ibm.com>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com> <20090608051608.GA19748@gondor.apana.org.au> <1244480687.18220.36.camel@w-sridhar.beaverton.ibm.com> <20090608233739.GA1021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	rusty@rustcorp.com.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090608233739.GA1021@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Jun 08, 2009 at 10:04:47AM -0700, Sridhar Samudrala wrote:
>   
>> OK. Can we use skb_segment() to do IP fragmentation of UDP packets?
>>     
>
> It should be able to.
>   
Unfortunately, this doesn't work for UDP without any changes. 
skb_segment() currently adds transport header to
each segmented skb. But when we are using IP fragmentation, only the 
first fragment should include the UDP
header.
We either need to fix skb_segment() to handle IP fragmentation or write 
a new skb_fragment(). I will look into
this when i get some time.

Thanks
Sridhar

>   
>> The function itself looks protocol independent and if it is simply
>> splitting large skb into a list of mtu sized skb's, can we fixup the
>> ip header differently for UDP packets(id and frag_off) in inet_gso_segment
>> and ipv6_gso_segment?
>>     
>
> Yes that's the idea.
>
> Cheers,
>   


