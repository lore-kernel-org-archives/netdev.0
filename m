From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
 redundant?
Date: Fri, 25 Jul 2008 21:38:57 -0700 (PDT)
Message-ID: <20080725.213857.160776686.davem@davemloft.net>
References: <20080725152059.GA4656@gerrit.erg.abdn.ac.uk>
	<488A88C5.1070105@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750729AbYGZEi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 00:38:58 -0400
In-Reply-To: <488A88C5.1070105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 25 Jul 2008 22:15:33 -0400

> Gerrit Renker wrote:
> >  * icmp_unreach() in net/ipv4/icmp.c already has this test:
> > 
> > 	/* Checkin full IP header plus 8 bytes of protocol to
> > 	 * avoid additional coding at protocol handlers.
> > 	 */
> >         if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
> >                 goto out;

I just noticed that this won't bump the ICMP MIB counter.

The ICMP code will only bump the counter if the IP header isn't there,
or has a bogus header length.

But it is clear in the callers that the intention is (or was) to bump
the counter if the 8 bytes of post IP header bits are not there.
