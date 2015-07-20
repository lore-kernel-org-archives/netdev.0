From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Mon, 20 Jul 2015 14:14:59 +0800
Message-ID: <20150720061459.GA12023@gondor.apana.org.au>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
 <2115027.IFUsFvOUns@stwm.de>
 <20150717015651.GA19315@gondor.apana.org.au>
 <10491450.MOzxZjY76n@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34578 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbbGTGPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 02:15:07 -0400
Content-Disposition: inline
In-Reply-To: <10491450.MOzxZjY76n@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 05:38:30PM +0200, Wolfgang Walter wrote:
>
> eth1 stops sending with the patch after some time
> disabling gro on eth0 helps
> disabling tso or gso on eth0 and/or eth1 or both does not help
> 
> eth0 and eth1 are both intel I350.

What does ethtool -k eth1 say?

Can you confirm that disabling tso on eth1 does not help?

Because the most plausible explanation is that we're feeding
some bogus TSO packet to the hardware causing a tx lockup.

But in any case if it is a hardware lockup then it's no longer
just a pure software bug.  No matter what we do in the stack
the hardware should not lock up (unless of course we're feeding
it something that's completely bogus).

If we can't figure this out then the safest solution would be
to disable tunnel GRO completely because it's broken as it stands.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
