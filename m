From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] xfrm: Fix refcount imbalance in xfrm_lookup
Date: Thu, 24 Jul 2014 00:54:38 +0200
Message-ID: <1406156078.3363.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
	 <1406103487-1656-2-git-send-email-steffen.klassert@secunet.com>
	 <1406136073.3363.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140723.150938.1689093120175055002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:50122 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbaGWWyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:54:54 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so8583082wib.9
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 15:54:53 -0700 (PDT)
In-Reply-To: <20140723.150938.1689093120175055002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-23 at 15:09 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > Hmm... are you sure ?
> > 
> > Before 1a1ccc96abb we did a dst_hold() because we kept the dst in
> > xfrm_policy_sk_bundles. So keeping a reference count was mandatory.
> > 
> > But after, I don't understand why it is needed at all.
> 
> It should be needed.
> 
> We create a new bundle here, from scratch, based upon the socket
> policy.
> 
> Such new bundles make routes with dst refcount == 0.
> 
> All callers expect that the route given back to them is either
> the original 'dst' passed into xfrm_lookup() unmolested, or a
> new 'dst' having a refcount taken for this caller.
> 
> That's why all call sites expect that they can just go
> "dst_release(dst)" and these objects it works.
> 
> So, if we returned 'dst' with refcount == 0 it would not work.

OK, I understood, thanks !
