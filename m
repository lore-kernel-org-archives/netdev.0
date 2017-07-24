From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib: test_rhashtable: fix for large entry counts
Date: Mon, 24 Jul 2017 14:14:18 -0700 (PDT)
Message-ID: <20170724.141418.2036891383541794115.davem@davemloft.net>
References: <20170721145131.25542-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, herbert@gondor.apana.org.au, netdev@vger.kernel.org,
        mm@skelett.io
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932299AbdGXVOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:14:19 -0400
In-Reply-To: <20170721145131.25542-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri, 21 Jul 2017 16:51:31 +0200

> During concurrent access testing, threadfunc() concatenated thread ID
> and object index to create a unique key like so:
> 
> | tdata->objs[i].value = (tdata->id << 16) | i;
> 
> This breaks if a user passes an entries parameter of 64k or higher,
> since 'i' might use more than 16 bits then. Effectively, this will lead
> to duplicate keys in the table.
> 
> Fix the problem by introducing a struct holding object and thread ID and
> using that as key instead of a single integer type field.
> 
> Fixes: f4a3e90ba5739 ("rhashtable-test: extend to test concurrency")
> Reported by: Manuel Messner <mm@skelett.io>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks Phil.
