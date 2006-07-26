From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Wed, 26 Jul 2006 12:40:45 -0700
Message-ID: <1153942845.3167.56.camel@rh4>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793B29B@nekter>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>,
	"David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, steve.arden@neterion.com,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2822 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S932378AbWGZTjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 15:39:33 -0400
To: "Dan Reader" <Dan.Reader@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7793B29B@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-14 at 12:12 -0400, Dan Reader wrote:

> If we implement the approach you suggest and all data sent uses TSO, the
> receiver can easily determine the expected codepoint of almost any
> isolated CE packet.  It simply has to look at the segment before and the
> segment after (which it can wait for, thanks to delayed ACKs).  If they
> have the same ECT value, use that one.  If they're different, then it
> just has to perform a check for non-MSS (i.e. the boundary between TSOs
> if send ops do not yield a multiple of MSS) and it might know.

I don't think it's that easy to guess.  The TSO sizes are almost always
multiples of MSS because they get trimmed or they are limited by the
congestion window.  The receiver will eventually make a mistake using
your scheme above that the sender can reliably detect.

I agree that replicating the ECT bits makes it less random, but it seems
to be the simplest and best approach.  In real life, there will be some
TSO and some non-TSO packets making it even more difficult to guess.
Randomizing the ECT bits in hardware makes verification of the nonce-sum
very complicated and unreliable.


