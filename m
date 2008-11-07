From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 20:25:38 +0300
Message-ID: <20081107172538.GA15239@ioremap.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz> <20081101.211541.182428064.davem@davemloft.net> <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yavor Goulishev <yavor@simplifymedia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:57845 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080AbYKGRZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 12:25:40 -0500
Content-Disposition: inline
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 11:38:14AM -0500, Yavor Goulishev (yavor@simplifymedia.com) wrote:
> OK, but this is mainly achieved with good hash function and proper table size.
> My original patch wouldn't change the locations(buckets) of the ports. It will just chose different ports.
> The hack for picking a good port number just looks for empty bucket.

Your original patch just added full check into bucket selection
algorithm, so that you could jump into the next bucket early.

> > If you will add any other fields into hash in inet_csk_get_port(), this
> > will not change anything, since it will just switch hash table bucket to
> > be checked. When we found hash bucket for given port, all its entries
> > are checked to have the same parameters as in provided data. See how
> > bind_conflict() callback is invoked in inet_csk_get_port().
> 
> It would change. Switching the bucket allows you to grow the table size and keep O(1).
> Without changing the hash function, growing the table size will not help.
> Currently all binds on the same port will go to the same bucket.

Listen sockets have a priviledge to steal ports, so they can not be
accessed by any other bind, if you will distribute sockets with the
same port over the whole table, listen sockets will not caught this.

-- 
	Evgeniy Polyakov
