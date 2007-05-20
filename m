From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1
Date: Sun, 20 May 2007 20:55:47 +1000
Message-ID: <E1Hpj4l-0006lF-00@gondolin.me.apana.org.au>
References: <464E30B7.3030107@intel.com>
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com (Kok, Auke)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1203 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756007AbXETKz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 06:55:57 -0400
In-Reply-To: <464E30B7.3030107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>
>> The source file has four extra lines at the top because of a
>> trivial wireless patch, so 898 in that code is really 894 in
>> the stock kernel.
> 
> please shared that code then.

I've had a look and e1000 is definitely buggy.

The problem is that you're calling netif_poll_enable on startup.
This is *wrong*.

netif_poll_enable can only be called if you've previously called
netif_poll_disable.  Otherwise a poll might already be in action
and you may get a crash like this.

So perhaps you should divide e1000_up into two sections, one that
is called on both start and restart and another which is only
called on restart (i.e., after e1000_down).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
