From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: don't attempt to grow when at max_size
Date: Thu, 23 Apr 2015 11:59:19 -0400 (EDT)
Message-ID: <20150423.115919.1353583175267783165.davem@davemloft.net>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch,
	johannes.berg@intel.com, herbert@gondor.apana.org.au
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966289AbbDWP7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 11:59:22 -0400
In-Reply-To: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 23 Apr 2015 16:38:43 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> The conversion of mac80211's station table to rhashtable had a bug
> that I found by accident in code review, that hadn't been found as
> rhashtable apparently managed to have a maximum hash chain length
> of one (!) in all our testing.
> 
> In order to test the bug and verify the fix I set my rhashtable's
> max_size very low (4) in order to force getting hash collisions.
> 
> At that point, rhashtable WARNed in rhashtable_insert_rehash() but
> didn't actually reject the hash table insertion. This caused it to
> lose insertions - my master list of stations would have 9 entries,
> but the rhashtable only had 5. This may warrant a deeper look, but
> that WARN_ON() just shouldn't happen.
> 
> Fix this by not returning true from rht_grow_above_100() when the
> rhashtable's max_size has been reached - in this case the user is
> explicitly configuring it to be at most that big, so even if it's
> now above 100% it shouldn't attempt to resize.
> 
> This fixes the "lost insertion" issue and consequently allows my
> code to display its error (and verify my fix for it.)
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

It looks fine to me, but I'll let Herbert and Thomas review this.
