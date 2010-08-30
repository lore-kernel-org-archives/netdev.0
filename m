From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Mon, 30 Aug 2010 10:40:19 -0700
Message-ID: <20100830174018.GA3639@bougret.hpl.hp.com>
References: <20100827210240.GC4703@outflux.net> <20100827212254.GB32275@bougret.hpl.hp.com> <1283158058.3691.10.camel@jlt3.sipsolutions.net> <1283158704.3691.11.camel@jlt3.sipsolutions.net> <1283162341.3691.45.camel@jlt3.sipsolutions.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:50348 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755439Ab0H3Rkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 13:40:53 -0400
Content-Disposition: inline
In-Reply-To: <1283162341.3691.45.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 11:59:01AM +0200, Johannes Berg wrote:
> 
> Ok I finally fully understood the issue.
> 
> This will fix the problem, but the comment is completely bogus, which I
> guess means you didn't actually understand the problem.

	Correct, Kees pointed out that my comment was bogus and the
e-mail I sent after the patch corrected myself on that point :

------------------------------------
> The comment should probably be clarified -- it's the caller's iwp->length
> that may be causing problems

        Ha ! I see. It would be for regular iwpoint queries, not for
extended NOMAX queries (scan is a extended NOMAX query).
------------------------------------

> My patch also didn't fix the problem, I didn't understand the problem
> correctly and was continuously wondering how drivers would ever fill the
> buffer with more than max_tokens (which would be a more serious bug,
> since they'd overwrite a slab object after "extra").

	Yes, I had arrived at the same conclusion (not that my patch
did fix the issue).

> What really fixes the problem is the patch below though. Had to realise
> that the path where the driver didn't do ANYTHING AT ALL was the
> problem....

	I actually like your patch better than mine, it's closer to
the original intent of the API. Go for it ;-)

> johannes

	Thanks a lot for the second pair of eyes.

	Jean
