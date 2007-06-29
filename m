From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Fri, 29 Jun 2007 09:02:41 +0200
Message-ID: <20070629070241.GA1908@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net> <20070628091339.GC1618@ff.dom.local> <4683A848.5040907@trash.net> <20070628130335.GA3284@ff.dom.local> <4683AFD7.8080605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:37705 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756183AbXF2Gy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 02:54:27 -0400
Content-Disposition: inline
In-Reply-To: <4683AFD7.8080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 02:55:51PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Thu, Jun 28, 2007 at 02:23:36PM +0200, Patrick McHardy wrote:
> > 
> >>Jarek Poplawski wrote:
> >>
> >>>>@@ -202,7 +201,6 @@ void gen_kill_estimator(struct gnet_stats_basic 
> >>>>*bstats,
> >>>>	struct gen_estimator *est, **pest;
> >>>>
> >>>>	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
> >>>>-		int killed = 0;
> >>>>		pest = &elist[idx].list;
> >>>>		while ((est=*pest) != NULL) {
> >>>
...
> Its overkill in that case. The concurrent additions and removals
> can't happen.

BTW, if we talk about overkills: is there any reason to do these
for & while until the end? I can't see why anybody should add the
same *bstats & *rate_est more than once (or max twice if we let
to add, change & remove them independently). With a large number
of classes this could matter.

Regards,
Jarek P.
