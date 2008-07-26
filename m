From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
 redundant?
Date: Sat, 26 Jul 2008 00:36:17 -0700 (PDT)
Message-ID: <20080726.003617.265743493.davem@davemloft.net>
References: <488A88C5.1070105@hp.com>
	<20080725.213857.160776686.davem@davemloft.net>
	<20080726070308.GA4674@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751309AbYGZHgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 03:36:17 -0400
In-Reply-To: <20080726070308.GA4674@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 26 Jul 2008 08:03:08 +0100

> If `goto out' is replaced with `goto out_err' in icmp_unreach(),
> it may be worth considering the analogous case in icmpv6_notify():
> 
> 	/* Checkin header including 8 bytes of inner protocol header. */
>         if (!pskb_may_pull(skb, inner_offset+8))
>                 return;
> 
> and the `discard_it' jump label in icmpv6_rcv().

What if the lower protocol doesn't have a header that it
at least 8 bytes? :-)

I think that's yet another reason why the check and counter bump were
originally down in the per-protocol hander.
