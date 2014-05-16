From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 10:13:50 -0700
Message-ID: <1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516104014.607d2d0f@vostro>
	 <1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516173443.0b40157e@vostro>
	 <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516194037.4486cd63@vostro>
	 <1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516200112.114cf1bb@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37953 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaEPRNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:13:52 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so2802878pad.25
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:13:52 -0700 (PDT)
In-Reply-To: <20140516200112.114cf1bb@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 20:01 +0300, Timo Teras wrote:
Documentation/oops-tracing.txtscripts/decodecode
> I believe it crashes, but cannot say with 100% certainty. I can
> test later on if needed. Based on earlier experiment, the only way to
> avoid the crash was to turn off gro on gre1.
> 
> In any case I don't think it should make any effect, since the GRE
> packets arrive IPseced. eth0 is receiving ESP packets - and I believe
> there's no ESP GRO support. Only after decryption they go to gre1, so
> gre1 gro is basically the place where received packets are coalesced.

Oh this is definitely useful.

I thought we might have a problem now with have GRE enabled GRO in
native GRO layer. I was wondering if the double attempt to GRO packets a
second time was a problem.

So it looks like ESP provides packets that are not very gentle for
skb_gro_receive()...

Could you provide scripts/decodecode output ?

Thanks
