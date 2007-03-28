From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Wed, 28 Mar 2007 21:34:36 +0200
Message-ID: <20070328193436.GP521@postel.suug.ch>
References: <20070327133845.GM521@postel.suug.ch> <20070328111921.GA2703@ff.dom.local> <20070328154903.GO521@postel.suug.ch> <20070328.112417.08322226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@o2.pl, netdev@vger.kernel.org, muli@il.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36093 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933239AbXC1TeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 15:34:16 -0400
Content-Disposition: inline
In-Reply-To: <20070328.112417.08322226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-03-28 11:24
> Another idea Thomas and I tossed around was to have some kind of way
> for the rule insertion to indicate that the flush should be deferred
> and I kind of prefer that explicitness.

Right, although I believe the flag should not only defer it
but not flush at all. This would be the optimal solution
for scripts which can do a ip ro flush cache as they know
what they're doing.

> By default it's better the flush immediately, because the old
> behavior is totally unexpected.  "I insert a rule and it dosn't
> show up?", nobody expects that.

It's a tough call, I'd favour immediate flush as well but I can
see the point in delaying by ip_rt_min_delay which can be
configured by the user. So people can choose to immediately flush
by setting it to 0. It would also be consistent to the flush
after route changes, the same delay is used there.
