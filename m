From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [RESEND][PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 31 Jul 2007 11:01:59 +0200
Message-ID: <20070731090159.GB12071@florz.florz.dyndns.org>
References: <20070729060423.GA27573@florz.florz.dyndns.org> <20070730.174721.17862949.davem@davemloft.net> <20070731080719.GA12071@florz.florz.dyndns.org> <20070731.012609.41193630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.169.56] ([77.10.169.56]:45112 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbXGaJCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 05:02:06 -0400
Content-Disposition: inline
In-Reply-To: <20070731.012609.41193630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Erm, I'd say this not only produces different results than the old
> > version, but it also produces "wrong" results, in that it ignores quite
> > a bit of the data that's supposed to be hashed. If I didn't overlook
> > something, it only considers addr&0x0f0f0f0f0f00 and sid&0x0f0f, given
> > the right endianness of addr and that PPPOE_HASH_SIZE stays 16.
> 
> You're right, I need to fix the shifts up.  How does this version
> look?
> 
> 	hash ^= (hash >> 4) ^ (hash >> 12) ^ (hash >> 20);
> 	return (head ^ (hash >> 8) ^ (hash >> 24)) &
> 		(PPPOE_HASH_SIZE - 1);

Assuming that it was supposed to read s/head/hash/: Same disclaimers
apply, but I'd say this considers only addr&0xff0fff0f000f and
sid&0x0fff, so, well, yes, it's better, but still not quite what I
think it should be ;-)

> Actually it might be simpler and more efficient to just make
> PPPOE_HASH_SHIFT be 8.

SHIFT? SIZE? BITS?

Florian
