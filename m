From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH] Have af-specific init_tempsel() initialize family field of temporary selector
Date: Tue, 04 Nov 2008 12:46:44 +0100
Message-ID: <87ljvziuhn.fsf@natisbad.org>
References: <87hc6npz4c.fsf@natisbad.org>
	<20081104112424.GB11049@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:60841 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988AbYKDLsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 06:48:33 -0500
In-Reply-To: <20081104112424.GB11049@gondor.apana.org.au> (Herbert Xu's
	message of "Tue, 4 Nov 2008 19:24:24 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Tue, Nov 04, 2008 at 11:24:51AM +0100, Arnaud Ebalard wrote:
>> Hi,
>> 
>> While adding MIGRATE support to strongSwan, Andreas Steffen noticed that
>> the selectors provided in XFRM_MSG_ACQUIRE have their family field
>> uninitialized (those in MIGRATE do have their family set).
>> 
>> Looking at the code, this is because the af-specific init_tempsel()
>> (called via afinfo->init_tempsel() in xfrm_init_tempsel()) do not set
>> the value.
>> 
>> Even if current apps probably do not rely on it, is there any argument
>> for not doing it or is it just an omission?
>> 
>> The patch below is more for discussion than anything else.
>
> We should ask the MIP6 folks since this may affect them.

Sorry Herbert, my initial comment was misleading: the family is not set
in the selectors provided in the *XFRM_MSG_ACQUIRE*, which is not MIPv6 
related. I could check again, but I think the patch below will impact
all native key managers. Or did I miss something and there is a specific
reason why MIPv6 folks may be impacted?

>> Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
>> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
>> ---
>>  net/ipv4/xfrm4_state.c |    1 +
>>  net/ipv6/xfrm6_state.c |    1 +
>>  2 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
>> index 07735ed..55dc6be 100644
>> --- a/net/ipv4/xfrm4_state.c
>> +++ b/net/ipv4/xfrm4_state.c
>> @@ -33,6 +33,7 @@ __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
>>  	x->sel.dport_mask = htons(0xffff);
>>  	x->sel.sport = xfrm_flowi_sport(fl);
>>  	x->sel.sport_mask = htons(0xffff);
>> +	x->sel.family = AF_INET;
>>  	x->sel.prefixlen_d = 32;
>>  	x->sel.prefixlen_s = 32;
>>  	x->sel.proto = fl->proto;
>> diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
>> index 89884a4..60c78cf 100644
>> --- a/net/ipv6/xfrm6_state.c
>> +++ b/net/ipv6/xfrm6_state.c
>> @@ -34,6 +34,7 @@ __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
>>  	x->sel.dport_mask = htons(0xffff);
>>  	x->sel.sport = xfrm_flowi_sport(fl);
>>  	x->sel.sport_mask = htons(0xffff);
>> +	x->sel.family = AF_INET6;
>>  	x->sel.prefixlen_d = 128;
>>  	x->sel.prefixlen_s = 128;
>>  	x->sel.proto = fl->proto;
>
> Cheers,

