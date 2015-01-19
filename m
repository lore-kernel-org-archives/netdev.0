From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Tue, 20 Jan 2015 09:36:35 +1100
Message-ID: <20150119223635.GA8735@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
 <20141201102522.GA16579@gondor.apana.org.au>
 <20141231133923.GA30248@gondor.apana.org.au>
 <2797327.cCdE9QefP4@storm>
 <CANn89i+U-PFbuUrp08s3Ec8BmjPFq1zj8Aj2=vPVO4-iiLkTuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36942 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbASWgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 17:36:50 -0500
Content-Disposition: inline
In-Reply-To: <CANn89i+U-PFbuUrp08s3Ec8BmjPFq1zj8Aj2=vPVO4-iiLkTuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 09:19:48AM -0800, Eric Dumazet wrote:
> Zero sized packets are valid, just take a look at tcpdump ;)

But zero-sized packets in the send queue are not valid and will
not ever be cleaned, which is what triggered the original bug.

Although I'm not sure whether a WARN_ON will actually help since
it won't tell you why there is a zero-sized packet on the queue,
just the fact that there is.  You'll know you've got a zero-sized
packet on the queue anyway by looking at the tcpdump.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
