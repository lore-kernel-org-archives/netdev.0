From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 04:45:03 +0200
Message-ID: <1335926703.22133.39.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
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
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37427 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758440Ab2EBCpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 22:45:09 -0400
Received: by wibhq7 with SMTP id hq7so141322wib.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 19:45:07 -0700 (PDT)
In-Reply-To: <4FA03D69.6060907@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 12:45 -0700, Alexander Duyck wrote:

> I wasn't worried about the kfree vs put_page, I was worried about the
> coalesce case.  However, it looks like you are correct and I am not
> seeing any issues so everything seems to be working fine.
> 
> I have a hacked together ixgbe up and running now with the new build_skb
> logic and RSC/LRO disabled.  It looks like it is giving me a 5%
> performance boost for small packet routing, but I am using more CPU for
> netperf TCP receive tests and I was wondering if you had seen anything
> similar on the tg3 driver?
> 



Hmm, tg3 perf for small packets is not changed, because tg3 uses
copybreak anyway.

#define TG3_RX_COPY_THRESHOLD       256

For big packets, I have no changes in netperf because GRO cannot really
provide big enough skbs at 1Gb speed.

The changes are noticeable when BDP (Bandwidth*Delay Product) is large
and some packet losses happen : You notice lower latencies in TCP stack,
because of less collapses (big copies)
