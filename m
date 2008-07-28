From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)	redundant?
Date: Mon, 28 Jul 2008 14:09:55 -0400
Message-ID: <488E0B73.8070701@hp.com>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk> <488DC63A.3070309@hp.com> <20080728170846.GB3762@gerrit.erg.abdn.ac.uk> <488E0192.9030406@hp.com> <20080728174432.GA15892@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:36220 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbYG1SJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 14:09:58 -0400
In-Reply-To: <20080728174432.GA15892@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
> | > In TCP, the 8 bytes happen to be enough for doing sequence number checks. Other
> | > protocols have different header lengths and semantics. Thus doing the checks
> | > at the transport layer makes more sense than in the ICMP handler.
> | > 
> | > RFC 1122 is almost 20 years old, from a time before IPcomp, SCTP, or DCCP.
> | 
> | So the suggestion really is then to remove the length check icmp_unreach()?
> | 
> Yes, but there are a large number of handlers in which the check is absent
> (TCPv4, SCTPv4 and DCCP are exceptions). This would need to be added.
> 
> The ipv6/icmp.c code agrees with your suggestion of using 8 bytes as
> lower bound.
> 
> I did not want to jump to the conclusion of writing a patch, since there are
> more complex uses of ICMP (such as in a nested tunnel, perhaps with IPsec).
> This needs to be understood.
> 

Well, simply from the ICMP protocol perspective the 8 byte lower bound is all
that's required.  Each tunnel decapsulation point would have to provide it's own
additional validation on top of the 8 byte, but everyone should be guaranteed at
least 8 bytes for IPv4 ICMP errors.

The IPv6 checks are much different.  The MUST requirement is to provide as much
data as possible upto IPv6 min mtu.  So, the IPv6 icmp code should probably look
to see if min(payload_len, min_mtu) is provided.

-vlad
