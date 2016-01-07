From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] MTU changes and other fixes
Date: Thu, 07 Jan 2016 14:57:50 -0500 (EST)
Message-ID: <20160107.145750.213741381921685070.davem@davemloft.net>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcAGT5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:57:54 -0500
In-Reply-To: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue,  5 Jan 2016 11:57:27 +0000

> v2:
>  - add first patch (return error on fail).

You didn't read my feedback, so I'm not going to read your patches.

Is that OK with you?  I personally think it's fair.

I said that you need to reorganize how you do the MTU
changes.

You _MUST_ try to allocate the resources (queues, data
structures, whatever) for the new MTU size.

And if that fails, release those new resources and leave
the device exactly in the state it was in prior to the MTU
change call.

This means you can't use the close/open scheme, I'm explicitly
telling you not to use that mechanism to change the MTU because
it can leave the device inoperative if the re-open fails.

That is completely unexpected behavior for the user.

The interface must remain up and functioning at the original
MTU if the MTU change operation fails.  Your code does not
do this.

Yes, this is a lot of more work, but that's the only correct
way to implement this.

If you fail to implement this properly one more time I will start
simply ignoring your patch submissions for a while because you will be
completely wasting my time.

Thanks.
