From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: xfrm selector generating IKE
Date: Tue, 24 Feb 2009 09:23:39 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:21933 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754584AbZBXRXl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 12:23:41 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090224020839.GC18696@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

are you sure that works. the xfrm code in the kernel does not look at
the policy selector when checking port numbers to see if it should reuse
an existing SA. It only looks at the selector on the SA - this is why
racoon has a problem. The policy selector has the correct portness in it
but the SA does not. I have not tested it but I suspect openswan has the
same issue since it passes in an empty SA selector


-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
Sent: Monday, February 23, 2009 6:09 PM
To: Paul Moore
Cc: kaber@trash.net; davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: xfrm selector generating IKE

On Mon, Feb 23, 2009 at 05:31:29PM -0800, Paul Moore wrote:
> Do you know which version of *swan generates xfrm selectors when it
does
> an SA ADD or UPDATE. I downloaded openswan 2.6.19 and it does not

The selector logic doesn't work very well with nested tunnels
which is why I didn't use it for the original Openswan port.
We rely on the policy selector instead to do the job.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
