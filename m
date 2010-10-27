From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 13:39:32 -0700
Message-ID: <AANLkTi=AyYrmSWDTZVWb2s+jgnyjNyHo-fkV4U+Fm45n@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
	<4CC78F19.9080504@hp.com>
	<AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
	<AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34132 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756952Ab0J0Ujd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 16:39:33 -0400
Received: by wyf28 with SMTP id 28so1135014wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 13:39:32 -0700 (PDT)
In-Reply-To: <AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The current privacy address comes back because it's a time-based hash.

I would guess it uses jiffies (or some other equally fine-grained
time, or just pulls from a random entropy source),

I see no reason why the second time around it would generate the same
privacy address.
In other words: are you absolutely certain of this?  It's certainly
not how I would expect it to function.

v2.6.36/net/ipv6/addrconf.c
#ifdef CONFIG_IPV6_PRIVACY
#include <linux/random.h>
#endif

and

http://lxr.linux.no/linux+v2.6.36/net/ipv6/addrconf.c#L1608

static int __ipv6_regen_rndid(struct inet6_dev *idev) {
        get_random_bytes(idev->rndid, sizeof(idev->rndid));
        idev->rndid[0] &= ~0x02;

certainly seem to point towards it being totally random.

> I think the old ones are gone. Still, I think it's better that
> connections from 1 day ago don't work any more (the default for
> privacy addresses is 1 day), than if all new and all old connections
> don't work any more.

No, the default is _no more_ than 1 day preferred and 7 days valid.
But those are the upper maximums, the actual values are the
preferred/validity values taken from the RA (limited to whatever the
max limit sysctls are set to).
