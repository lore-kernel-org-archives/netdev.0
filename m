From: David Miller <davem@davemloft.net>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Tue, 10 Jun 2008 15:49:29 -0700 (PDT)
Message-ID: <20080610.154929.168124808.davem@davemloft.net>
References: <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
	<20080606183926.GB12651@elte.hu>
	<1212782937.23706.46.camel@tng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, ilpo.jarvinen@helsinki.fi, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, rjw@sisk.pl,
	akpm@linux-foundation.org, johnpol@2ka.mipt.ru
To: mcmanus@ducksong.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753657AbYFJWtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:49:33 -0400
In-Reply-To: <1212782937.23706.46.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McManus <mcmanus@ducksong.com>
Date: Fri, 06 Jun 2008 16:08:57 -0400

> If we're sure of that conclusion we should just take Ilpo's DA patch as
> that will narrow the field for finding Hakon's issue.

While the conclusion might be accurate, Ilpo's patch adds a lock
ordering problem that might introduce potential deadlocks (worst
case) or at least some lockdep warnings.  Both of which are
unacceptable.

I personally don't see any clear solution, and because this new
DA code moves an operation into a code block where the locking
order pretty much has to be inverted, I don't see any real short
term solution other than a revert of this particular DA commit.
