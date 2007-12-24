From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] skge csum problems
Date: Mon, 24 Dec 2007 19:45:23 +0000
Message-ID: <20071224194523.GA27894@ZenIV.linux.org.uk>
References: <20071224094352.GU8181@ftp.linux.org.uk> <p73sl1sp72b.fsf@bingen.suse.de> <20071224183950.GA5024@ZenIV.linux.org.uk> <20071224113638.0de0f189@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32795 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbXLXTpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 14:45:24 -0500
Content-Disposition: inline
In-Reply-To: <20071224113638.0de0f189@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 24, 2007 at 11:36:38AM -0800, Stephen Hemminger wrote:
> > you will get the same behaviour on big- and little-endian boxen, even though
> > the intermediate integer values will be of course different.
> > 
> > skb->csum *must* be stored in the same order on l-e and b-e boxen; that
> > way you don't need to convert it or raw data when updating the sucker [*].
> > 
> > [*] it's slightly more complicated since skb->csum is 4-byte, not 2-byte
> > and the real invariant is "checksum of 4-octet array at &skb->csum must
> > not depend on host" (so e.g XX YY 00 00 and 00 00 XX YY are equivalent -
> > checksum doesn't change from reordering octet pairs; XX YY 00 00 and
> > 00 00 YY XX are very definitely *NOT* equivalent; odd and even bytes
> > can't be exchanged).
> 
> Did you test this on real hardware?

Test _what_ on real hardware?  That kernel expects skb->csum fixed-endian?
That csum_add() and friends work?  Yes to both.

If you are asking whether I'd tested what skge does to csum in its rx
descriptors when asked to byteswap - as I've said, all skge-handled stuff
I have is on-board in little-endian boxen.  Thus asking for folks who
could test it on big-endian and see what does that sucker actually do...
