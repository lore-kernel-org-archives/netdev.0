From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Thu, 28 Jun 2007 15:03:35 +0200
Message-ID: <20070628130335.GA3284@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net> <20070628091339.GC1618@ff.dom.local> <4683A848.5040907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:52281 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758258AbXF1MzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 08:55:23 -0400
Content-Disposition: inline
In-Reply-To: <4683A848.5040907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 02:23:36PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >>@@ -202,7 +201,6 @@ void gen_kill_estimator(struct gnet_stats_basic 
> >>*bstats,
> >> 	struct gen_estimator *est, **pest;
> >> 
> >> 	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
> >>-		int killed = 0;
> >> 		pest = &elist[idx].list;
> >> 		while ((est=*pest) != NULL) {
> >
> >So, maybe this list walking here needs some locking too?
> 
> It depends on whether estimators should be able to rely on
> the rtnl in the future or be completely responsible for their
> own locking. My patch yesterday was made under the assumption
> that they shouldn't rely on external locking, which seemed to
> be the right thing for a "generic" implementation. OTOH its
> still specific to networking, so relying on the rtnl doesn't
> sound too unreasonable too. I'm beginning to thing I made
> the wrong choice with my patch.
> 
> I'm busy right now, would you mind looking into a patch that
> only deals with the timer races, but still relies on the
> rtnl?

In that case this patch looks OK & enough.

My earlier proposals are only of cosmetical value.

Jarek P.
