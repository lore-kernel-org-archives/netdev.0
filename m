From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Tue, 09 Jul 2013 21:41:56 -0700 (PDT)
Message-ID: <20130709.214156.1738814737075691376.davem@davemloft.net>
References: <20130709162514.062f1361@lwn.net>
	<20130709.160611.636749585237773459.davem@davemloft.net>
	<51DCD50C.6070606@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, dwmw2@infradead.org,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab3GJEl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 00:41:57 -0400
In-Reply-To: <51DCD50C.6070606@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 10 Jul 2013 06:29:16 +0300

> If the following names changes are acceptable I will try to send out
> a patch today.
> 
> 1. include/net/ll_poll.h -> include/net/busy_poll.h

Agreed.

> 2. ndo_ll_poll -> ndo_busy_poll
> 
> - not technically accurate since the ndo callback does not itself busy
> poll, it's just used to implement it.

I think this name change is accurate, it expresses the two elements of
what it does.  It's busy waiting, in that it's doing a synchronous
scan of the device's RX queue, and it's polling just like NAPI polling
does.

> maybe ndo_napi_id_poll? or ndo_id_poll? I don't really like any of them,
> so a suggestion would be nice.

This would make it sound like it's some new version of the existing
NAPI poll.

Well... what would be great would be to come up with some single
interface that drivers can implement rather than having to have
both napi->poll and netdevice_ops->ndo_ll_poll().  But that's a task
for a later date.

Therefore, ndo_busy_poll is probably best for now.

> 3. sysctl_net_ll_{read,poll} -> sysctl_net_busy_{read,poll}
> - along with matching file name changes.

Agreed.

> 4. {sk,skb}_mark_ll -> {sk,skb}_mark_napi_id

Agreed.

> 5. LL_SO -> BUSY_POLL_SO

Agreed.

> Did I miss anything?

Nope, looks complete.  And also do the manpage update.
