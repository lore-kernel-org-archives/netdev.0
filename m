From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Tue, 01 May 2012 08:39:38 +0200
Message-ID: <1335854378.11396.26.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49572 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab2EAGjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 02:39:43 -0400
Received: by were53 with SMTP id e53so11031wer.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 23:39:42 -0700 (PDT)
In-Reply-To: <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-30 at 22:33 -0700, Alexander Duyck wrote:

> The question I had was more specific to GRO.  As long as we have
> skb->users == 1 and the skb isn't cloned we should be fine.   It just
> hadn't occurred to me before that napi_gro_receive had the extra
> requirement that the skb couldn't be cloned.
> 

OK

By the way, even if skb was cloned, we would be allowed to steal
skb->head.

When we clone an oskb we :

1) allocate a struct nskb sk_buff (or use the shadow in case of TCP)
2) increment dataref
3) link skb->head

After cloning()  nskb->users == 1, and oskb->users is unchanged

I believe you are referring to skb_get(oskb), that ones increment
oskb->users and skb_shared(oskb) then returns true.
