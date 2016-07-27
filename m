From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/4] be2net: replace polling with sleeping in
 the FW completion path
Date: Wed, 27 Jul 2016 01:07:19 -0700 (PDT)
Message-ID: <20160727.010719.1596635131969198811.davem@davemloft.net>
References: <aa697cd90b7e1222de10b2e568b5396e@mail.gmail.com>
	<afdbd734835da306de6859a1495c87d6@mail.gmail.com>
	<105bbdcd07774b849f1636904db3e8f6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbcG0IHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 04:07:22 -0400
In-Reply-To: <105bbdcd07774b849f1636904db3e8f6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Wed, 27 Jul 2016 13:33:19 +0530

>> -----Original Message-----
>> From: Sathya Perla [mailto:sathya.perla@broadcom.com]
>> > >
>> > > > @@ -4477,6 +4551,22 @@ static int be_if_create(struct be_adapter
>> > *adapter)
>> > > >  	u32 cap_flags = be_if_cap_flags(adapter);
>> > > >  	int status;
>> > > >
>> > > > +	/* alloc required memory for other filtering fields */
>> > > > +	adapter->pmac_id = kcalloc(be_max_uc(adapter),
>> > > > +				   sizeof(*adapter->pmac_id), GFP_KERNEL);
>> > > > +	if (!adapter->pmac_id)
>> > > > +		return -ENOMEM;
>> > > > +
>> > > > +	adapter->mc_list = kcalloc(be_max_mc(adapter),
>> > > > +				   sizeof(*adapter->mc_list), GFP_KERNEL);
>> > > > +	if (!adapter->mc_list)
>> > > > +		return -ENOMEM;
>> > > > +
>> > > > +	adapter->uc_list = kcalloc(be_max_uc(adapter),
>> > > > +				   sizeof(*adapter->uc_list), GFP_KERNEL);
>> > > > +	if (!adapter->uc_list)
>> > > > +		return -ENOMEM;
>> > >
>> > > These error paths are leaking memory, please audit this in the rest
>> > > of
>> > your change as well.
>> >
>> > David, thanks for catching this; will fix this (and others if any) and
>> > send out a v2.
>>
>> David, actually, when be_if_create() returns an error, it falls back into
>> the error path of
>> be_setup() (the caller) and be_clear() is called. be_clear() calls
>> be_if_destroy() which frees the allocated memory.
>> So, this code will not leak memory in the error path.
> 
> David, can you accept the v1 patch set as-is, as it doesn't have the memory
> leaks that you suspected initially?

Please resubmit, thanks.
