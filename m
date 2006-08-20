From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 12:44:27 -0700 (PDT)
Message-ID: <20060820.124427.74745779.davem@davemloft.net>
References: <20060819234806.GB27115@1wt.eu>
	<200608200205.20876.mb@bu3sch.de>
	<20060820004307.GD27115@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12762
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751176AbWHTToR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 15:44:17 -0400
To: w@1wt.eu
In-Reply-To: <20060820004307.GD27115@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 20 Aug 2006 02:43:07 +0200

> On Sun, Aug 20, 2006 at 02:05:20AM +0200, Michael Buesch wrote:
> > Not to me. It heavily violates codingstyle and screws brains
>                 ^^^^^^^
> little exageration detected here.
> 
> > with the non-indented else branches.
> 
> while they surprized me first, they make the *patch* more readable
> by clearly showing what has been inserted and where. However, I have
> joined the lines for the merge.

Thanks for consulting the networking maintainer before merging
this. :-/

What if some sockopt treats a negative length specially?
Maybe some setsockopt() doesn't care about the optlen pointer?

This toplevel code has no buisness interpreting the arguments when the
downcall and argument interpretation is by definition protocol
specific.  It also means we'll touch userspace twice for this value
which is really dumb.

The only nice part about this change is that it allows us to be lazy
about auditing the individual setsockopt() implementations.  I'd
rather fix the broken cases than add a patch which just assumes they
are broken and not worth fixing, and also imposes a convention for the
optlen argument.

No thanks.

And yes the coding style was totally unacceptable too.
