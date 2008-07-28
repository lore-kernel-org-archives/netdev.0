From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
	redundant?
Date: Mon, 28 Jul 2008 18:44:32 +0100
Message-ID: <20080728174432.GA15892@gerrit.erg.abdn.ac.uk>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk> <488DC63A.3070309@hp.com> <20080728170846.GB3762@gerrit.erg.abdn.ac.uk> <488E0192.9030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56649 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755809AbYG1Rom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 13:44:42 -0400
Content-Disposition: inline
In-Reply-To: <488E0192.9030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > In TCP, the 8 bytes happen to be enough for doing sequence number checks. Other
| > protocols have different header lengths and semantics. Thus doing the checks
| > at the transport layer makes more sense than in the ICMP handler.
| > 
| > RFC 1122 is almost 20 years old, from a time before IPcomp, SCTP, or DCCP.
| 
| So the suggestion really is then to remove the length check icmp_unreach()?
| 
Yes, but there are a large number of handlers in which the check is absent
(TCPv4, SCTPv4 and DCCP are exceptions). This would need to be added.

The ipv6/icmp.c code agrees with your suggestion of using 8 bytes as
lower bound.

I did not want to jump to the conclusion of writing a patch, since there are
more complex uses of ICMP (such as in a nested tunnel, perhaps with IPsec).
This needs to be understood.

Gerrit
