From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Mon, 19 Jan 2015 14:39:26 +0100
Message-ID: <2797327.cCdE9QefP4@storm>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <20141201102522.GA16579@gondor.apana.org.au> <20141231133923.GA30248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:58343 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbbASNja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 08:39:30 -0500
In-Reply-To: <20141231133923.GA30248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Thursday, 1. January 2015 00:39:23 Herbert Xu wrote:
> The problem is that when the MSS goes down, existing queued packet
> on the TX queue that have not been transmitted yet all look like
> TSO packets and get treated as such.
> 
> This then triggers a bug where tcp_mss_split_point tells us to
> generate a zero-sized packet on the TX queue.  Once that happens
> we're screwed because the zero-sized packet can never be removed
> by ACKs.

picking up this one again: Is there any valid use case to have
zero-sized packets in the TX queue? If not, may be a WARN_ON() could
be added to the processing of the TX queue. That would help to
prevent future issues like this.

Cheers,
Thomas
