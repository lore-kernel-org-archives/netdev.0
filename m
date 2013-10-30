From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Wed, 30 Oct 2013 19:35:48 +0000
Message-ID: <1383161748.1601.24.camel@bwh-desktop.uk.level5networks.com>
References: <20131030172341.19203.93490.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42136 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab3J3Tfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:35:54 -0400
In-Reply-To: <20131030172341.19203.93490.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> 
> As described in commit 5a581b367 (jiffies: Avoid undefined
> behavior from signed overflow), according to the C standard
> 3.4.3p3, overflow of a signed integer results in undefined
> behavior.
[...]

According to the real processors that Linux runs on, signed arithmetic
uses 2's complement representation and overflow wraps accordingly.  And
we rely on that behaviour in many places, so we use
'-fno-strict-overflow' to tell gcc not to assume we avoid signed
overflow.  (There is also '-fwrapv' which tells gcc to assume the
processor behaves this way, but shouldn't it already know how the target
machine works?)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
