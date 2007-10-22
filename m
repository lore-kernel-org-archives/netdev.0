From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] remove netpoll receive code
Date: Mon, 22 Oct 2007 11:54:23 -0500
Message-ID: <20071022165423.GG17536@waste.org>
References: <20071017132131.1992bedd@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:46531 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbXJVQyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 12:54:37 -0400
Content-Disposition: inline
In-Reply-To: <20071017132131.1992bedd@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[annoyed as ever about never being cc:ed on this stuff]

On Wed, Oct 17, 2007 at 01:21:31PM -0700, Stephen Hemminger wrote:
> The netpoll receive code is:
> 1. Not used by any in-tree features, it is used by kgdb-over-ether.

And various crashdump over network tools.

> 2. A nice hook for people doing nasty things like private binary network stacks or rootkits.

It's a completely useless hook for a binary network stack. It only
supports UDP and only point to point. And it will have crap
performance. It's much less useful here than, say, TUN/TAP.

It doesn't buy anything for a rootkit either, which will continue to
trivially hide servers in userspace as they already do.

This point is completely FUD.

> 3. Unsecured by any of the normal firewalling code.

This is correct. It also applies to the TX side of things. The point,
of course, is to bypass as much of the stack as possible so that when
the kernel crashes, we're more likely to actually get our netpoll
data.

> I propose that we take out all the whole netpoll rx path. If/when
> kgdb gets submitted a better and alternative receive path can be
> added.

Let's hear about this better alternative first, shall we? I for one am
a little skeptical of its existence. Going through a larger fraction
of the network stack, running softirqs, etc., are all big (potentially
fatal) steps backward from the point of view of a debugger.

-- 
Mathematics is the supreme nostalgia of our time.
