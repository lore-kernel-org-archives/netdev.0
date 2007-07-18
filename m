From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Wed, 18 Jul 2007 12:49:16 +0200
Message-ID: <20070718104916.GJ11657@kernel.dk>
References: <Line.LNX.4.64.0707121608100.10773@d.namei> <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk> <1184575545.15112.0.camel@johannes.berg> <20070716120247.GG5195@kernel.dk> <1184711770.4658.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:29501 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbXGRKtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 06:49:43 -0400
Content-Disposition: inline
In-Reply-To: <1184711770.4658.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18 2007, Johannes Berg wrote:
> On Mon, 2007-07-16 at 14:02 +0200, Jens Axboe wrote:
> 
> > Yep, it's a sender thing, so upgrading the receiver will not change
> > anything.
> 
> Ok, I upgraded, but that didn't help. And in fact, I don't see how it
> could have since synergy doesn't use splice or sendfile. I should've
> thought of that right away, sorry.
> 
> It seems that packets are actually coming in during the time that my
> mouse hangs though (ran wireshark in parallel and saw no pauses in the
> timeline.) Hence, it actually seems to be on the receiver side, and
> running the synergy client under strace reveals that during the time my
> mouse hangs it's in poll() waiting for input on the tcp socket. sysrg-t
> doesn't show anything useful, it's just scheduling waiting for data.
> According to wireshark data is sent, but it never shows up at the
> application layer.

OK, then we can put splice off the hook at least :-)

If it's easily reproducible (and it sounds like it), then a git bisect
might be the easiest way forward.

-- 
Jens Axboe

