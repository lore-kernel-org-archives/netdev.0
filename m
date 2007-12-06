From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions of sysctl and proc handler for conf.all.forwarding
Date: Fri, 7 Dec 2007 04:42:56 +1100
Message-ID: <20071206174256.GB530@gondor.apana.org.au>
References: <E1J04N1-0006uU-00@gondolin.me.apana.org.au> <4757EB92.4010400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1850 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751462AbXLFRxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:53:15 -0500
Content-Disposition: inline
In-Reply-To: <4757EB92.4010400@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 06, 2007 at 03:31:14PM +0300, Pavel Emelyanov wrote:
>
> BTW, this is not 100% true. Look, in rtm_to_ifaddr()
> I see the following code flow:
> 
>         ipv4_devconf_setall(in_dev);
> 
>         ifa = inet_alloc_ifa();
>         if (ifa == NULL) {
>                 /*
>                  * A potential indev allocation can be left alive, it stays
>                  * assigned to its device and is destroy with it.
>                  */
>                 err = -ENOBUFS;
>                 goto errout;
>         }
> 
> if we fail to allocate the ifa (hard to happen, but), we will
> make this device not to accept the default propagation.

Yes that's unintentional.

> If this is a relevant note, I can prepare the patch.

It certainly seems easy enough to fix by just swapping the order.
Please do.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
