From: David Miller <davem@davemloft.net>
Subject: Re: network interface state
Date: Wed, 14 Nov 2007 16:22:01 -0800 (PST)
Message-ID: <20071114.162201.174150647.davem@davemloft.net>
References: <473B61C8.3030302@redhat.com>
	<20071114.153103.230463871.davem@davemloft.net>
	<473B8EEC.1010906@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756233AbXKOAWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 19:22:01 -0500
In-Reply-To: <473B8EEC.1010906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 Nov 2007 16:12:28 -0800

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> David Miller wrote:
> > Most daemons handle this by listening for events on the netlink
> > socket, but I understand how that might not be practical for
> > glibc.
> 
> Right, this cannot work.  I have no inner loop which I can control.  I
> cannot install a listener.
> 
> At some point, when we have non-sequential, hidden file descriptors,
> I'll be able to leave a socket file descriptor open.  But that's about
> it.  Even then the generation counter interface is likely to be the best
> choice.

Ok, I'll think about how to implement this.

> BTW, is it possible to send both these requests out before starting to
> read the results?  This would reduce the amount of code quite a bit.

Unfortunately, that won't work.  Like datagram protocols,
netlink assumes one message per sendmsg() call.
