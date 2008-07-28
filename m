From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Mon, 28 Jul 2008 18:08:46 +0100
Message-ID: <20080728170846.GB3762@gerrit.erg.abdn.ac.uk>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk> <488DC63A.3070309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54336 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760165AbYG1RJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 13:09:39 -0400
Content-Disposition: inline
In-Reply-To: <488DC63A.3070309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  * only TCP/SCTP seem to have a proper per-protocol "payload too short" test;
| 
| Hm..  In the standard case, these do seem to be redundant since 8 bytes are required
| by ICMP spec.
| 
| >  * for DCCP, the work is actually doubled since 
| >    - first the ICMP handler tests for minimally 8 bytes, 
| >    - then the DCCP error handler tests for required minimum of 12 bytes.
| 
| DCCP and any other protocol that requires more error data should check for it in
| its own handler.  8 bytes should be guaranteed to such handler.
| 
| What am I missing?
| 
As per last message, please disregard the patch suggestion made at the
beginning of the thread.

In TCP, the 8 bytes happen to be enough for doing sequence number checks. Other
protocols have different header lengths and semantics. Thus doing the checks
at the transport layer makes more sense than in the ICMP handler.

RFC 1122 is almost 20 years old, from a time before IPcomp, SCTP, or DCCP.
