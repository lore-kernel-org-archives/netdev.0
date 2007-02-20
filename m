From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Tue, 20 Feb 2007 16:44:33 -0500
Message-ID: <20070220214433.GA22467@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca> <20070219201136.GH7585@csclub.uwaterloo.ca> <20070219221845.GI7585@csclub.uwaterloo.ca> <20070219222920.GJ7585@csclub.uwaterloo.ca> <20070219234548.GK7585@csclub.uwaterloo.ca> <20070219235916.GL7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:53453 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030430AbXBTVoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 16:44:34 -0500
Content-Disposition: inline
In-Reply-To: <20070219235916.GL7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 06:59:16PM -0500, Lennart Sorensen wrote:
> I am also noticing the receive error count going up, and the source is
> this code:
> 
> if (status & 0x01)      /* Only count a general error at the */
>        lp->stats.rx_errors++;  /* end of a packet. */
> 
> It appears this means I am receiving a frame marked with "End Of Packet"
> but without "Start of Packet".  I have no idea how that happens, but it
> shouldn't be able to make the driver and MAC stop processing the receive
> ring.

Well the packets actually have both start and end marked, but also have
overflow marked, so the cpu simply isn't keeping up it seems (It is
taking about 100% of the cpu to push through 6500KB/s).  Certainly the
CONFIG_X86_OOSTORE makes a major difference, although I am still not
sure why.  Simply skipping ahead one or two receive descriptors when the
current one is marked as owned by the MAC but the one a few ahead is
owned by the CPU allows it to continue receiving when it happens.  I
really want to find out why it happens though, although I am not sure
how to go about doing that.

--
Len Sorensen
