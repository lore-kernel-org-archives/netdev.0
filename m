From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Wed, 23 Mar 2016 18:39:57 -0700
Message-ID: <1458783597.10868.60.camel@edumazet-glaptop3.roam.corp.google.com>
References: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
	 <1458739547.10868.37.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160323132947.GA29938@gondor.apana.org.au>
	 <1458754165.10868.41.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324004514.GA3110@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	'Steffen Klassert' <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, jeromes@codeaurora.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32817 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757001AbcCXBkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 21:40:01 -0400
Received: by mail-pf0-f180.google.com with SMTP id 4so44498974pfd.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 18:40:00 -0700 (PDT)
In-Reply-To: <20160324004514.GA3110@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 08:45 +0800, Herbert Xu wrote:
> On Wed, Mar 23, 2016 at 10:29:25AM -0700, Eric Dumazet wrote:
> >
> > OK, but before calling netif_rx() are we properly testing dev->flags
> > IFF_UP status ?
> > 
> > Otherwise, we still allow packets being queued after flush_backlog() had
> > been called.
> 
> That's the first thing enqueue_to_backlog tests.
> 
> Cheers,

Seems to be very recent stuff ( commit
e9e4dd3267d0c5234c5c0f47440456b10875dec9 in linux-4.2)

In the old days the test was done in callers, since in most cases NIC
drivers do not need it.

Lets make sure this was backported to all stable trees.

And then we probably can cleanup some callers as well.
