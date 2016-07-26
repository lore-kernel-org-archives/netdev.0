From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [net-next PATCH 4/4] be2net: replace polling with sleeping in the
 FW completion path
Date: Tue, 26 Jul 2016 12:48:25 +0530
Message-ID: <aa697cd90b7e1222de10b2e568b5396e@mail.gmail.com>
References: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
	<1469184946-26309-5-git-send-email-sathya.perla@broadcom.com> <20160725.105130.1337790235000032163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:36319 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbcGZHS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 03:18:28 -0400
Received: by mail-yw0-f169.google.com with SMTP id u134so187809879ywg.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 00:18:28 -0700 (PDT)
In-Reply-To: <20160725.105130.1337790235000032163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
>
> > @@ -4477,6 +4551,22 @@ static int be_if_create(struct be_adapter
*adapter)
> >  	u32 cap_flags = be_if_cap_flags(adapter);
> >  	int status;
> >
> > +	/* alloc required memory for other filtering fields */
> > +	adapter->pmac_id = kcalloc(be_max_uc(adapter),
> > +				   sizeof(*adapter->pmac_id), GFP_KERNEL);
> > +	if (!adapter->pmac_id)
> > +		return -ENOMEM;
> > +
> > +	adapter->mc_list = kcalloc(be_max_mc(adapter),
> > +				   sizeof(*adapter->mc_list), GFP_KERNEL);
> > +	if (!adapter->mc_list)
> > +		return -ENOMEM;
> > +
> > +	adapter->uc_list = kcalloc(be_max_uc(adapter),
> > +				   sizeof(*adapter->uc_list), GFP_KERNEL);
> > +	if (!adapter->uc_list)
> > +		return -ENOMEM;
>
> These error paths are leaking memory, please audit this in the rest of
your change as well.

David, thanks for catching this; will fix this (and others if any) and
send out a v2.
