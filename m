From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6646] New: UDP socket doesn't return to bound
 state after association is dissolved by connect(..AF_UNSPEC)
Date: Sat, 10 Jun 2006 18:10:26 -0700 (PDT)
Message-ID: <20060610.181026.21594839.davem@davemloft.net>
References: <200606050658.k556wJ8X032608@fire-2.osdl.org>
	<20060605000751.f3bc7ed3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yujiang.wang@sun.com,
	bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49623
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750827AbWFKBKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 21:10:24 -0400
To: akpm@osdl.org
In-Reply-To: <20060605000751.f3bc7ed3.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 5 Jun 2006 00:07:51 -0700

> > When disconnect a UDP socket, Linux kernel set local port to zero if the port
> > number comes from a implicit bind. Linux connect(2) man page reads:
> > "Generally, connection-based protocol sockets may successfully *connect* only
> > once; connectionless protocol sockets may use *connect* multiple times to change
> > their association. Connectionless sockets may dissolve the association by
> > connecting to an address with the /sa_family/ member of *sockaddr* set to
> > *AF_UNSPEC*."
> > But dissolve the association should not impact the local binding, while
> > currently it does. In contrast, Unix variants like Solaris don't alter local
> > binding when disconnecting a UDP socket. 

You can only preserve the parts of a local binding which are
explicitly specified.  Since you make an explicit bind to a source
address, that will be preserved by the disconnect.

However, since you use a zero anonymous port during the bind,
the one choosen by the kernel will not be preserved.  If you
had choosen an explicit port during bind() it would be preserved
by the disconnect.

This behavior is intentional and will not change.
