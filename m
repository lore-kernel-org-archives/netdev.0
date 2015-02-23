From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 21:03:58 +0000
Message-ID: <20150223210358.GB806@casper.infradead.org>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
 <20150223191201.GA4355@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	kaber@trash.net, davem@davemloft.net, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: josh@joshtriplett.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42080 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbbBWVEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 16:04:00 -0500
Content-Disposition: inline
In-Reply-To: <20150223191201.GA4355@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/15 at 11:12am, josh@joshtriplett.org wrote:
> In theory, resizes should only take the locks for the buckets they're
> currently unzipping, and adds should take those same locks.  Neither one
> should take a whole-table lock, other than resize excluding concurrent
> resizes.  Is that still insufficient?

Correct, this is what happens. The problem is basically that
if we insert from atomic context we cannot slow down inserts
and the table may not grow quickly enough.

> Yeah, the add/remove statistics used for tracking would need some
> special handling to avoid being a table-wide bottleneck.

Daniel is working on a patch to do per-cpu element counting
with a batched update cycle.
