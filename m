From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Mon, 10 Sep 2012 21:42:45 -0400 (EDT)
Message-ID: <20120910.214245.368123682481775366.davem@davemloft.net>
References: <1347281326-26890-2-git-send-email-amwang@redhat.com>
	<20120910.163229.421777922179988802.davem@davemloft.net>
	<1347326362.30731.9.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab2IKBmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 21:42:47 -0400
In-Reply-To: <1347326362.30731.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 11 Sep 2012 09:19:22 +0800

> On Mon, 2012-09-10 at 16:32 -0400, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Mon, 10 Sep 2012 20:48:45 +0800
>> 
>> > It doesn't save any code, nor it helps readability.
>> > 
>> > Signed-off-by: Cong Wang <amwang@redhat.com>
>> 
>> I'm not applying this.
>> 
>> Having two copies of the same exact logic means we will accumulate
>> bugs in the future if someone fixes the problem only in one
>> copy.
> 
> Makes sense, but BACKTRACK() is not well written, as it jumps out of its
> definition. :(

Anyone who has worked with longest-matching-prefix TRIE traversal
functions will have a pretty good idea what is going on here.

Yes, I know this conflicts with cases like how we killed all of
the netlink macros with embedded gotos.

But this patch made things worse and added code duplication.  Fix
it without the code duplication side effect and it'll be fine.
