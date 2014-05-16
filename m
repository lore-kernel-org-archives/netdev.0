From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 09:29:29 -0700
Message-ID: <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516104014.607d2d0f@vostro>
	 <1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516173443.0b40157e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:47585 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbaEPQ3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:29:31 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so2779419pab.0
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 09:29:31 -0700 (PDT)
In-Reply-To: <20140516173443.0b40157e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 17:34 +0300, Timo Teras wrote:

> Ah, did not notice that one. So I'm adding Herbert as explicit cc.
> 
> $ git describe --contains 9d8506cc2d7ea1f911c72c100193a3677f6668c3
> v3.13-rc1~7^2
> 
> But as you may have noticed, the attached oops is from 3.14.4 that
> includes the fix commit. While bisecting, I tested multiple versions
> between 3.12 and 3.14. Bisecting clearly points this is the commit that
> introduces this oops, and it is not fixed in any version up until
> 3.14.4.
> 
> Also the forward path from gre->ethX goes to eth that does not have
> TSO/GSO support. So I'd assume that the fix commit is not that
> relevant in my specific test case.
> 
> The faulty commit must be introducing additional bug, and the commit
> you refer did not fix it.

Right. The commit could expose a dormant bug in a driver.

For example, some drivers might forget to use skb_put()

Please give us more details.

What is the driver receiving ethernet frames ?

Is it using GRO ?
