From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Mon, 19 Feb 2007 18:45:48 -0500
Message-ID: <20070219234548.GK7585@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca> <20070219201136.GH7585@csclub.uwaterloo.ca> <20070219221845.GI7585@csclub.uwaterloo.ca> <20070219222920.GJ7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:40014 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965553AbXBSXpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 18:45:49 -0500
Content-Disposition: inline
In-Reply-To: <20070219222920.GJ7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 05:29:20PM -0500, Lennart Sorensen wrote:
> I just noticed, it seems almost all these problems occour right at the
> start of transfers when the tcp window size is still being worked out
> for the connection speed, and I am seeing the error count go up in
> ifconfig for the port when it happens too.  Is it possible for an error
> to get flagged in a receive descriptor without the owner bit being
> updated?

It seems the problem actually occours when the receive descriptor ring
is full.  This seems to generate one (or sometimes more) descriptors in
the ring which claim to be owned by the MAC, but at the head of the
receive ring as far as the driver is concerned.  I see some note in the
driver about an SP3G chipset sometimes causing this.  How would one
identify this and clear such descriptors out of the way?  Getting stuck
until the next time the MAC gets around to the descriptor and overwrites
it is not good, since it causes delays, and out of order packets.

--
Len Sorensen
