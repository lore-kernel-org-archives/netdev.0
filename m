From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] skge csum problems
Date: Thu, 27 Dec 2007 11:31:46 -0800
Message-ID: <20071227113146.758f0cce@deepthought>
References: <20071224094352.GU8181@ftp.linux.org.uk>
	<p73sl1sp72b.fsf@bingen.suse.de>
	<20071224183950.GA5024@ZenIV.linux.org.uk>
	<20071224113638.0de0f189@speedy>
	<20071224194523.GA27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48553 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751977AbXL0Tcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 14:32:45 -0500
In-Reply-To: <20071224194523.GA27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Dec 2007 19:45:23 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Dec 24, 2007 at 11:36:38AM -0800, Stephen Hemminger wrote:
> > > you will get the same behaviour on big- and little-endian boxen, even though
> > > the intermediate integer values will be of course different.
> > > 
> > > skb->csum *must* be stored in the same order on l-e and b-e boxen; that
> > > way you don't need to convert it or raw data when updating the sucker [*].
> > > 
> > > [*] it's slightly more complicated since skb->csum is 4-byte, not 2-byte
> > > and the real invariant is "checksum of 4-octet array at &skb->csum must
> > > not depend on host" (so e.g XX YY 00 00 and 00 00 XX YY are equivalent -
> > > checksum doesn't change from reordering octet pairs; XX YY 00 00 and
> > > 00 00 YY XX are very definitely *NOT* equivalent; odd and even bytes
> > > can't be exchanged).
> > 
> > Did you test this on real hardware?
> 
> Test _what_ on real hardware?  That kernel expects skb->csum fixed-endian?
> That csum_add() and friends work?  Yes to both.
> 
> If you are asking whether I'd tested what skge does to csum in its rx
> descriptors when asked to byteswap - as I've said, all skge-handled stuff
> I have is on-board in little-endian boxen.  Thus asking for folks who
> could test it on big-endian and see what does that sucker actually do...

I'll wait for 2.6.25 then. I am just concerned about how real hardware
interprets the byte swap PCI flag. I'll see if I can find some cost
competitive bigendian hardware.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
