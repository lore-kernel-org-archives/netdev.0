From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 14:09:54 -0400
Message-ID: <52714B72.2060200@redhat.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>	<20131029.194446.2215574000648693370.davem@davemloft.net>	<1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>	<20131029.220253.1263087684709722001.davem@davemloft.net>	<1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>	<20131030040818.GB2755@gondor.apana.org.au>	<1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>	<20131030041959.GA3162@gondor.apana.org.au>	<1383107681.4857.33.camel@edumazet-glaptop.roam.corp.google.com>	<20131030044212.GA3364@gondor.apana.org.au> <CAPshTCg8j-y6fGfh0tRMir34-Lzy77qyzibvwjMSMpR0Rr1rsA@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: Jerry Chu <hkchu@google.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab3J3SKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 14:10:20 -0400
In-Reply-To: <CAPshTCg8j-y6fGfh0tRMir34-Lzy77qyzibvwjMSMpR0Rr1rsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2013 01:39 PM, Jerry Chu wrote:
> On Tue, Oct 29, 2013 at 9:42 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>> On Tue, Oct 29, 2013 at 09:34:41PM -0700, Eric Dumazet wrote:
>>>
>>> What matters ?
>>>
>>> GRO ?
>>
>> What matters is that you should not treat the forwarding case
>> separately from the host case.
>>
>> For virtualisation the host case looks exactly like the forwarding
>> case.
>
>
> Not sure I agree - there are two different "forwarding" cases - forwarding
> to another physical NIC (to go out to the wire hence need to do GSO),
> and (for virtualization) forwarding to a virtual NIC and consumed internally
> (e.g., VM).

I don't think you can really differentiate these 2 case.  VM are
very commonly used as routers/forwarders.  In some cases, to get
better throughput,  VFs are assigned to the VMs as the externally
facing ports.  So, you still end up forwarding to another physical
NIC.

-vlad

> For the latter we should strive to push GSO pkts all the way
> to the VM stack w/o breaking them up. So for virtualization GRO is all
> goodness but not sure about the regular forwarding path. (From the
> perf perspective it boils down to if the cost of GSO/GRO will offset
> the benefit of GRO. Sure if one manages to get the cost close to zero
> than there is not reason to leave GRO always on. But it's still a big if for
> now.)
>
> Best,
>
> Jerry
>
>>
>>
>> IOW, if having a 64KB packet matters for the host, then it matters
>> for forwarding as well.
>>
>>> Before my patch, GRO packets were 17 MSS, and nobody complained packets
>>> were too small, so what are you saying exactly ?
>>
>> I'm not criticsing your mega-GRO patch at all.  That one is great
>> and means that we'll get aggregated packets up to 64K.  What we need
>> to do is just to patch up the GSO code so that it can handle these
>> mega-packets properly.
>>
>> Cheers,
>> --
>> Email: Herbert Xu <herbert@gondor.apana.org.au>
>> Home Page: http://gondor.apana.org.au/~herbert/
>> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
