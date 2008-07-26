From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
	redundant?
Date: Sat, 26 Jul 2008 08:03:08 +0100
Message-ID: <20080726070308.GA4674@gerrit.erg.abdn.ac.uk>
References: <20080725152059.GA4656@gerrit.erg.abdn.ac.uk> <488A88C5.1070105@hp.com> <20080725.213857.160776686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63838 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751786AbYGZHDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 03:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20080725.213857.160776686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  * icmp_unreach() in net/ipv4/icmp.c already has this test:
| > 
| > 	/* Checkin full IP header plus 8 bytes of protocol to
| > 	 * avoid additional coding at protocol handlers.
| > 	 */
| >         if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
| >                 goto out;
| 
| I just noticed that this won't bump the ICMP MIB counter.
| 
| The ICMP code will only bump the counter if the IP header isn't there,
| or has a bogus header length.
| 
| But it is clear in the callers that the intention is (or was) to bump
| the counter if the 8 bytes of post IP header bits are not there.
| 
If `goto out' is replaced with `goto out_err' in icmp_unreach(),
it may be worth considering the analogous case in icmpv6_notify():

	/* Checkin header including 8 bytes of inner protocol header. */
        if (!pskb_may_pull(skb, inner_offset+8))
                return;

and the `discard_it' jump label in icmpv6_rcv().
