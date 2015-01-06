From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/5] rhashtable: use future table size to make
 expansion decision
Date: Tue, 6 Jan 2015 10:06:14 +0000
Message-ID: <20150106100614.GF12468@casper.infradead.org>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
 <1420529003-22244-4-git-send-email-ying.xue@windriver.com>
 <20150106093557.GC12468@casper.infradead.org>
 <54ABB147.6020904@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53151 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbbAFKGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 05:06:17 -0500
Content-Disposition: inline
In-Reply-To: <54ABB147.6020904@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 05:56pm, Ying Xue wrote:
> Thank you for above nice explanation. Regarding my understanding, as
> rhashtable_expand() and rhashtable_shrink() are always under the
> protection of "ht->mutex", the "future_tbl" and "tbl" absolutely point
> to the same bucket array once rhashtable_expand() or rhashtable_shrink()
> returns. Therefore, if rht_deferred_worker() takes the "ht->mutex" lock,
> the both "future_tbl" and "tbl" should point to the same bucket array.
> So the change made in the patch is useless for us, right?

Correct.

> But as you pointed in above patch, there is a bug in
> rhashtable_wakeup_worker(). As long as ht->tbl == ht->future_tbl, we
> should wake up the work. OK, I will drop the patch and fix the error in
> patch #2.

Awesome, thanks!
