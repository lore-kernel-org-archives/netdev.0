From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
	redundant?
Date: Mon, 28 Jul 2008 12:25:27 +0100
Message-ID: <20080728112527.GB7589@gerrit.erg.abdn.ac.uk>
References: <20080727045121.GA419@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33342 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276AbYG1L0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 07:26:54 -0400
Content-Disposition: inline
In-Reply-To: <20080727045121.GA419@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for the input. To sum up,
 * removing the per-protocol "ICMP payload too short" test and error counter
   increment as initially suggested does not seem right;
 * there are protocols such as IPComp which have a header length less than
   8 bytes(and for these the test in the ICMP handler may be too much);
 * there are protocols such as DCCP which need more than 8 bytes (at least 12)
   to interpret the ICMP message in a meaningful way;
 * the requirement of having at least 8 bytes of transport-layer data available
   is stringent (afaik) only for ICMPv4, but not ICMPv6;
 * only TCP/SCTP seem to have a proper per-protocol "payload too short" test;
 * for DCCP, the work is actually doubled since 
   - first the ICMP handler tests for minimally 8 bytes, 
   - then the DCCP error handler tests for required minimum of 12 bytes.

Thus the patch at the begginning of this thread should be disregarded.
It might be worth to consider per-protocol handlers.

Gerrit
