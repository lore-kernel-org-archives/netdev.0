From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 12:54:28 +0200
Message-ID: <20060825105428.GR3470@postel.suug.ch>
References: <44EED0FC.4050108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:54476 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751436AbWHYKyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 06:54:07 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44EED0FC.4050108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-08-25 12:29
> This patch adds support to mask the nfmark value before the lookup
> the the fw classifier. Unfortunately it has some drawbacks, so I'd
> be interested if anyone can think of a better way.
> 
> The problem is that in order to avoid walking through all filters
> contained in one instance, we need to mask the value before the
> lookup. This means all filters share the same mask, which is
> taken from the first filter created and stored in the filter head.
> The user interface however always refers to a single filter,
> not the head, so it can't be changed afterwards unless we just
> overwrite it whenever a new filter is installed. Both is not
> really perfect. The current patch doesn't allow to change the
> mark and enforces that all filters use the same one, which I think
> is better than allowing inconsistent configurations.

The other option gets down to replacing the hash table with a
list and that's not an option in my opinion. This looks very
good to me.
