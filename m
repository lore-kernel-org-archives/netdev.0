From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 19:13:50 -0700
Message-ID: <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.194446.2215574000648693370.davem@davemloft.net>
	<1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.220253.1263087684709722001.davem@davemloft.net>
	<20131030020543.GA1925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:36292 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3J3CNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:13:51 -0400
Received: by mail-ve0-f178.google.com with SMTP id db12so532640veb.37
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 19:13:51 -0700 (PDT)
In-Reply-To: <20131030020543.GA1925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 7:05 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Oct 29, 2013 at 10:02:53PM -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 29 Oct 2013 17:53:48 -0700
>>
>> > So should we apply the first fix to avoid the BUG_ON() ?
>>
>> Please be more specific, are you talking about splitting up
>> this patch in some way?
>
> I think Eric is referring to the patch that removes the BUG_ON
> in skb_segment and deals with the new mega-GRO packets.
>
> I think that's fine for stable, but for the long term we should
> fix it properly as these new meag-GRO packets still retain the
> existing packet boundaries and are trivially segmentable.
>
> If we are indeed able to do that, I doubt we would even need
> the sysctl patch since the GRO performance should be vastly
> superior to the non-GRO case, even for a router/bridge.

Probably not the case for the simple forwarding case. See my
test result of some small (5-8%) CPU+throughput penalty from
GRO (over GRE tunnel) posted previously. But I can believe
the number may be very different if the forwarding path involves
more work (NAT, iptables filtering,...,etc) resulting in a higher per
pkt cost.

Best,

Jerry

>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
