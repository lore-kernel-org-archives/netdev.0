From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Interface for TCP Metrics
Date: Wed, 22 Aug 2012 22:47:59 -0700 (PDT)
Message-ID: <20120822.224759.1531662436208583166.davem@davemloft.net>
References: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab2HWFsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:48:00 -0400
In-Reply-To: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 19 Aug 2012 14:42:15 +0300 (EEST)

> - will use genl with TCP_METRICS_GENL_NAME "tcp_metrics",
> TCP_METRICS_GENL_VERSION 0x01

Sounds good.

> - provide dumpit method and one cmd to read metrics by exact addr,
> will use TCP_METRICS_CMD_{GET,...} and TCP_METRICS_ATTR_xxx in
> new file include/linux/tcp_metrics.h

Ok.

Eric thinks we can filter in userspace, but since it's so easy to
lookup entries in the kernel and the demux for that is already there,
I have no objections to have a bonafide netlink operation for
getting a single entry.

> - Is command to delete cached entry needed? Delete will need
> new rcu_head. Useful to flush the cache or to delete entries
> with filter.

Having a way to flush the entire table is useful.  Specific entries,
is less useful.

> - without support for delete cmd, may be we can add command to
> reset entry with default values from dst?
> 
> - Where to put the new netlink code?
> tcp_metrics_netlink.c
> tcp_metrics_nl.c
> or just in current tcp_metrics.c ?

Put it in tcp_metrics.c, that way we don't need to export any
internals.

> - command to modify specific metric for addr, by name? Only
> for tcpm_vals? If not locked?
> 
> 	Do we need modify/delete/reset support or just read
> support is enough? Comments?

I would say that you can support fancy things as long as new
locking constraints are not added.
