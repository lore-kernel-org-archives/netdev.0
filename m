From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Wed, 26 Jul 2006 06:01:40 +0200
Message-ID: <44C6E924.2010902@trash.net>
References: <E1G5ZBx-00084U-00@gondolin.me.apana.org.au> <44C6E39F.8010602@trash.net> <20060726034650.GA3393@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, zdzichu@irc.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11002 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030376AbWGZEDS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 00:03:18 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060726034650.GA3393@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Patrick:
> 
> On Wed, Jul 26, 2006 at 05:38:07AM +0200, Patrick McHardy wrote:
> 
>>I have a patch which changes netfilter to do incremental checksumming.
>>The hook number is passed to all functions doing this so they know
>>how to update the checksum. Could you explain how
>>CHECKSUM_COMPLETE/CHECKSUM_PARTIAL are going to be used? I assume
>>they're meant to avoid passing hook numbers around everywhere?
> 
> 
> Yes the hook number is another way to solve the same problem.  However,
> it can only be used within netfilter.  CHECKSUM_COMPLETE/CHECKSUM_PARTIAL
> on the other hand are valid throughout the stack.  With Xen feeding Linux
> packets into the stack the netfilter hook is also no longer sufficient to
> distinguish between these two cases as partial checksum packets can now
> appear on receive.
> 
> The problem is that you need to do different incremental updates depending
> on whether the checksum is complete (i.e., CHECKSUM_HW on receive), or
> partial (i.e., CHECKSUM_HW on transmit).
> 
> With complete checksums the current update code in netfilter can be used
> as is.  With partial checksums you need to exclude bits which weren't
> used when computing the partial checksums (e.g., TCP port numbers need
> to be excluded, but the IP address needs to be included for NAT).

That does sound better than the hook number approach.

> I have a patch that adds CHECKSUM_COMPLETE/CHECKSUM_PARTIAL if you want
> something to work from.  Let me know if you want this and I'll bounce it
> to you.

Please send it, I'll update my patch based on that. Thanks.

