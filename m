From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [net-next PATCH 4/4] be2net: replace polling with sleeping in the
 FW completion path
Date: Wed, 27 Jul 2016 13:33:19 +0530
Message-ID: <105bbdcd07774b849f1636904db3e8f6@mail.gmail.com>
References: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
	<1469184946-26309-5-git-send-email-sathya.perla@broadcom.com>
 <20160725.105130.1337790235000032163.davem@davemloft.net> <aa697cd90b7e1222de10b2e568b5396e@mail.gmail.com>
 <afdbd734835da306de6859a1495c87d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:36087 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbcG0IDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 04:03:22 -0400
Received: by mail-yw0-f180.google.com with SMTP id u134so50137988ywg.3
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 01:03:21 -0700 (PDT)
In-Reply-To: <afdbd734835da306de6859a1495c87d6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sathya Perla [mailto:sathya.perla@broadcom.com]
> > >
> > > > @@ -4477,6 +4551,22 @@ static int be_if_create(struct be_adapter
> > *adapter)
> > > >  	u32 cap_flags = be_if_cap_flags(adapter);
> > > >  	int status;
> > > >
> > > > +	/* alloc required memory for other filtering fields */
> > > > +	adapter->pmac_id = kcalloc(be_max_uc(adapter),
> > > > +				   sizeof(*adapter->pmac_id), GFP_KERNEL);
> > > > +	if (!adapter->pmac_id)
> > > > +		return -ENOMEM;
> > > > +
> > > > +	adapter->mc_list = kcalloc(be_max_mc(adapter),
> > > > +				   sizeof(*adapter->mc_list), GFP_KERNEL);
> > > > +	if (!adapter->mc_list)
> > > > +		return -ENOMEM;
> > > > +
> > > > +	adapter->uc_list = kcalloc(be_max_uc(adapter),
> > > > +				   sizeof(*adapter->uc_list), GFP_KERNEL);
> > > > +	if (!adapter->uc_list)
> > > > +		return -ENOMEM;
> > >
> > > These error paths are leaking memory, please audit this in the rest
> > > of
> > your change as well.
> >
> > David, thanks for catching this; will fix this (and others if any) and
> > send out a v2.
>
> David, actually, when be_if_create() returns an error, it falls back into
> the error path of
> be_setup() (the caller) and be_clear() is called. be_clear() calls
> be_if_destroy() which frees the allocated memory.
> So, this code will not leak memory in the error path.

David, can you accept the v1 patch set as-is, as it doesn't have the memory
leaks that you suspected initially?

thanks,
-Sathya
