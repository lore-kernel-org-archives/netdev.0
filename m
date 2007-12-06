From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions of sysctl and proc handler for conf.all.forwarding
Date: Thu, 06 Dec 2007 11:13:39 +1100
Message-ID: <E1J04N1-0006uU-00@gondolin.me.apana.org.au>
References: <20071205.020645.171664472.davem@davemloft.net>
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3936 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751160AbXLFANn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 19:13:43 -0500
In-Reply-To: <20071205.020645.171664472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> The user is pretty much screwed in one way or the other.
> For example:
> 
> 1) If 'default' propagates to all devices, any specific
>   setting for a device is lost.
> 
> 2) If 'default' does not propagate, there is no way to
>   have 'default' influence devices which have already
>   been loaded.

Well the way it works on IPv4 currently (for most options) is
that we'll propagate default settings to a device until either:

1) the user modifies the setting for that device;
2) or that an IPv4 address has been added to the device.

2) was done to preserve backwards compatibility as the controls
were previously only available after address addition and we did
not propagate default settings in that case..

We could easily extend this so that the default propagation
worked until the user modified the setting, with an ioctl to
revert to the current behaviour for compatibility.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
