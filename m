From: David Miller <davem@davemloft.net>
Subject: Re: An ioctl to delete an ipv6 tunnel leads to a kernel panic
Date: Tue, 12 Feb 2008 21:49:46 -0800 (PST)
Message-ID: <20080212.214946.168597748.davem@davemloft.net>
References: <32209efe0802111249x16a6bbe0l4c152b3cf3aa0470@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: protasnb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752057AbYBMFtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 00:49:15 -0500
In-Reply-To: <32209efe0802111249x16a6bbe0l4c152b3cf3aa0470@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Mon, 11 Feb 2008 12:49:12 -0800

> Possible reason for this failure was identified and tested by the
> submitter and several other reporters that ran into the same problem.
> Can the patch be reviewed and pushed upstream if accepted (if the
> problem hasn't been addressed already)?

There are a lot of bogus patches in there, using funny
long variable names, and mainly they were meant for testing
and verification of the problem.

I see no real serious patch submissions in that bug and furthermore
the patch, if ready, should be submitted formally here to netdev not
rot in bugzilla.

Finally, what appears to be the proposal cannot be correct.  If the
fib6_add_rt2node() finds that the new route is a duplicate, we should
disconnect it from the fn->leaf and do a dst_release().  The bug
appears to be rather that we leave the route attached to the fn, not
that we drop the refrence to it.

Thank you.
