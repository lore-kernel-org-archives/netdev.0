From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls
 on v3.12+
Date: Mon, 1 Dec 2014 18:25:22 +0800
Message-ID: <20141201102522.GA16579@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44100 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbaLAKZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 05:25:29 -0500
Content-Disposition: inline
In-Reply-To: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> 
> When I revert it, even kernel v3.18-rc6 starts working.
> But I doubt this is the root problem, may be just hiding another issue.

Can you do a tcpdump with this patch reverted? I would like to
see the size of the packets that are sent out vs. the ICMP message
that came back.

My guess is that the IPsec GSO path is buggy since as you rightly
pointed out it couldn't have been heavily tested prior to this
patch.

Though I am surprised that it only breaks when you have a PMTU event
so it might be something else after all.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
