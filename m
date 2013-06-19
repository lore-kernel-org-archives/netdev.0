From: David Miller <davem@davemloft.net>
Subject: Re: nl80211 NULL pointer dereference
Date: Wed, 19 Jun 2013 00:47:11 -0700 (PDT)
Message-ID: <20130619.004711.1012726896714145860.davem@davemloft.net>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
	<20130618.190632.33329016434510583.davem@davemloft.net>
	<CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933328Ab3FSHrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 03:47:14 -0400
In-Reply-To: <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 18 Jun 2013 16:24:57 -1000

> And yes, the code checks that for being non-NULL in at the top of the
> function, but maybe there is a race with something else setting it to
> NULL? There is a kzalloc(GFP_KERNEL) in between, so it doesn't even
> have to be a very small race...

The nl80211 code uses a flag for each netlink command to determine
whether the RTNL mutex should be held across the operation.

This is handled in the pre_doit and post_doit methods implemented
in nl80211.c.

And this operation, in fact, just so happens to be one that doesn't
have the "take the RTNL mutex" flag set.

But for internal consistency of the netlink message itself, the RTNL
mutex should not matter.  It's in a private SKB buffer which is in use
only by the ->doit() method.
