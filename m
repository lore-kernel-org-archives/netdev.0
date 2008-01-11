From: linux@horizon.com
Subject: Re: [PATCH 0/4] Pull request for 'ipg-fixes' branch
Date: 10 Jan 2008 20:58:51 -0500
Message-ID: <20080111015851.25008.qmail@science.horizon.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Cc: akpm@linux-foundation.org, jeff@garzik.org, linux@horizon.com,
	netdev@vger.kernel.org
To: davem@davemloft.net, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:13394 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754273AbYAKB6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 20:58:54 -0500
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much, this appears to work.

> The driver is still a POMS but it seems better now.

I notice that the vendor-supplied driver doesn't have these bugs.
Now, it does have a bug in that it doesn't have an "is this
interrupt for me?" test at all (and always returns "I handled it"),
but the bypass and its locking screwups are a later addition.

The same with the sp->rx_current bugs.  The original loop which used
rx_current as the loop iteration variable wasn't great style, precisely
because it hides the interaction that someone's "optimization" broke,
but I don't want to blame the vendor for things they didn't do.

Would you be interested in some cleanup patches?  In particular, I think I
can get rid of tx->lock entirely, or at least take it off the fast path.
All it's protecting is the write to sp->tx_current, and a few judicious
memory barriers can deal with that.


(Oh, another BUG: the sp->ResetCurrentTFD logic in hard_start_xmit is
just plain broken.  It writes the new data to entry 0, then increments
sp->tx_current just like usual.  THAT isn't in the vendor driver that
I see, either.)
