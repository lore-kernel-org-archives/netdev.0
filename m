From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Thu, 28 Jun 2007 11:56:03 +0200
Message-ID: <20070628095603.GD1618@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net> <20070628065448.GA1618@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:58030 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758782AbXF1Jru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 05:47:50 -0400
Content-Disposition: inline
In-Reply-To: <20070628065448.GA1618@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 08:54:48AM +0200, Jarek Poplawski wrote:
...
> > @@ -215,10 +213,7 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
> >  			write_unlock_bh(&est_lock);
> >  
> >  			kfree(est);
> > -			killed++;
> >  		}
> > -		if (killed && elist[idx].list == NULL)
> > -			del_timer(&elist[idx].timer);
> 
> I think this is needed. The old timer could be pending, while
> the gen_new_estimator() is run just after this e.g. in
> gen_replace_estimator().

Sorry! I've forgotten there is mod_timer now, so, it's OK!

Jarek P.
