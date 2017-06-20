From: David Miller <davem@davemloft.net>
Subject: Re: dev: Reclaim network device indexes
Date: Tue, 20 Jun 2017 12:42:50 -0400 (EDT)
Message-ID: <20170620.124250.956500694842302363.davem@davemloft.net>
References: <20170616091659.3361b5d0@xeon-e3>
        <4d4b3b9dd459fc0487c1d25ef23514b9f01e4bb2.1497631012.git.serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdFTQmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 12:42:52 -0400
In-Reply-To: <4d4b3b9dd459fc0487c1d25ef23514b9f01e4bb2.1497631012.git.serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 19:39:34 +0300

> While making dev_new_index() return zero on overrun prevents
> from infinite loop, there is no way to recovery mechanisms
> since namespace ifindex only increases and never reused
> from released network devices.
> 
> To address this we introduce dev_free_index() helper which
> is used to reclaim released network device index when it is
> smaller than last allocated index in namespace.
> 
> This also has positive side effect for equal distribution
> of network devices per buckets in index hash table. That
> positively affects performance of dev_get_by_index() family.
> 
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

You haven't explained why the current behavior is undesirable,
and why we want reuse.

I don't think we want at all for anything to rely on ifindexes
being allocated one way or another.

Yes, I understand that hash table argument, but that can be solved
other ways.  And what you're talking about is more of an error case
not a normal case.
