From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net] neigh: do not modify unlinked entries
Date: Sun, 21 Jun 2015 09:43:58 -0700 (PDT)
Message-ID: <20150621.094358.971978257754152032.davem@davemloft.net>
References: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	ying.xue@windriver.com, alexei@purestorage.com,
	joern@purestorage.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbFUQcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:32:13 -0400
In-Reply-To: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 16 Jun 2015 22:56:39 +0300

> The lockless lookups can return entry that is unlinked.
> Sometimes they get reference before last neigh_cleanup_and_release,
> sometimes they do not need reference. Later, any
> modification attempts may result in the following problems:
> 
> 1. entry is not destroyed immediately because neigh_update
> can start the timer for dead entry, eg. on change to NUD_REACHABLE
> state. As result, entry lives for some time but is invisible
> and out of control.
> 
> 2. __neigh_event_send can run in parallel with neigh_destroy
> while refcnt=0 but if timer is started and expired refcnt can
> reach 0 for second time leading to second neigh_destroy and
> possible crash.
> 
> Thanks to Eric Dumazet and Ying Xue for their work and analyze
> on the __neigh_event_send change.
> 
> Fixes: 767e97e1e0db ("neigh: RCU conversion of struct neighbour")
> Fixes: a263b3093641 ("ipv4: Make neigh lookups directly in output packet path.")
> Fixes: 6fd6ce2056de ("ipv6: Do not depend on rt->n in ip6_finish_output2().")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks!
