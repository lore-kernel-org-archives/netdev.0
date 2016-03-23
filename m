From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Wed, 23 Mar 2016 10:29:25 -0700
Message-ID: <1458754165.10868.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
	 <1458739547.10868.37.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160323132947.GA29938@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	'Steffen Klassert' <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, jeromes@codeaurora.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34964 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135AbcCWR31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:29:27 -0400
Received: by mail-pf0-f170.google.com with SMTP id n5so35640374pfn.2
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:29:27 -0700 (PDT)
In-Reply-To: <20160323132947.GA29938@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-23 at 21:29 +0800, Herbert Xu wrote:
> On Wed, Mar 23, 2016 at 06:25:47AM -0700, Eric Dumazet wrote:
> >
> > Wont this prevent device from being dismantled ?
> 
> This is only held while the crypto processing is ongoing.
> 
> > Where is this xfrm queue purged at device dismantle ?
> 
> There is no way to cancel an ongoing crypto processing so you'll
> just have to wait it out.

OK, but before calling netif_rx() are we properly testing dev->flags
IFF_UP status ?

Otherwise, we still allow packets being queued after flush_backlog() had
been called.

Thanks.
