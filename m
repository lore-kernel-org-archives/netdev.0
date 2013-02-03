From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] netpoll: protect napi_poll and poll_controller
 during dev_[open|close]
Date: Sun, 03 Feb 2013 16:05:58 -0500 (EST)
Message-ID: <20130203.160558.164595629505218847.davem@davemloft.net>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
	<1359831076-32476-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595Ab3BCVGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:06:00 -0500
In-Reply-To: <1359831076-32476-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sat,  2 Feb 2013 13:51:16 -0500

> I can't say Im a huge fan of returning -EBUSY in open/close, but I
> like it better than busy waiting while the poll path completes.

Sorry Neil, this is a show stopper for me.

There is no reason why, just because of bad timing, a device open or
close that would normally succeed, should fail.  And this situation is
only being created because the mutual exclusion and context handling
is "hard", well that's too bad :-)
