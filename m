From: David Miller <davem@davemloft.net>
Subject: Re: tbl->lock not taken in neigh_lookup() ?
Date: Sun, 24 Jan 2016 21:20:45 -0800 (PST)
Message-ID: <20160124.212045.993259665260998708.davem@davemloft.net>
References: <CAOxq_8Okd4uLcj-MeLoms3mzpQhjX6t06fR6svDUeCV6VNEyAA@mail.gmail.com>
	<CAOxq_8Mj2kxq1r-MFGWCXBBE=7hi0ASy2p99=Tx4ageDTnMHtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	eric.dumazet@gmail.com
To: ani@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbcAYFUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 00:20:46 -0500
In-Reply-To: <CAOxq_8Mj2kxq1r-MFGWCXBBE=7hi0ASy2p99=Tx4ageDTnMHtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ani Sinha <ani@arista.com>
Date: Mon, 25 Jan 2016 10:11:15 +0530

> Can I get some insights into this? I am sure I am missing something.

The whole point of RCU locking is that read accesses in the fast paths
(lookups) do not need to take the spinlock.  Proper RCU barriers, RCU
deferred freeing of objects, and other things make it safe.
