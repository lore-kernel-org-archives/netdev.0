From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nl80211: fix attrbuf access race by allocating a
 separate one
Date: Wed, 19 Jun 2013 01:39:00 -0700 (PDT)
Message-ID: <20130619.013900.786603036908799505.davem@davemloft.net>
References: <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
	<1371628488.8349.3.camel@jlt4.sipsolutions.net>
	<1371630238.8349.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933755Ab3FSIjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 04:39:01 -0400
In-Reply-To: <1371630238.8349.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 19 Jun 2013 10:23:58 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Since my commit 3713b4e364, nl80211_dump_wiphy() uses the global
> nl80211_fam.attrbuf for parsing the incoming data. This wouldn't
> be a problem if it only did so on the first dump iteration which
> is locked against other commands in generic netlink, but due to
> space constraints in cb->args (the needed state doesn't fit) I
> decided to always parse the original message. That's racy though
> since nl80211_fam.attrbuf could be used by some other parsing in
> generic netlink concurrently.
> 
> For now, fix this by allocating a separate parse buffer (it's a
> bit too big for the stack, currently 1448 bytes on 64-bit). For
> -next, I'll change the code to parse into the global buffer in
> the first round only and then allocate a smaller buffer to keep
> the state in cb->args.
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
