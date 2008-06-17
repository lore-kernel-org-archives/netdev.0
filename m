From: David Miller <davem@davemloft.net>
Subject: Re: Killing sk->sk_callback_lock
Date: Mon, 16 Jun 2008 18:53:28 -0700 (PDT)
Message-ID: <20080616.185328.85842051.davem@davemloft.net>
References: <484F43A3020000760003F543@lucius.provo.novell.com>
	<4856C12F020000C700039679@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, GHaskins@novell.com,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: pmullaney@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752257AbYFQBx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:53:28 -0400
In-Reply-To: <4856C12F020000C700039679@lucius.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Patrick Mullaney" <pmullaney@novell.com>
Date: Mon, 16 Jun 2008 19:38:23 -0600

> The overhead I was trying to address was scheduler overhead.

Neither Herbert nor I are convinced of this yet, and you have
to show us why you think this is the problem and not (in
our opinion) the more likely sk_callback_lock overhead.

I am tiring of stating this over and over so please address
this in any future correspondance.

Once the task is woken up the first time, future calls to
these callback functions should do nothing other than take
the sk_callback_lock and test some state.

Since the task is awake already, wakeups should be bypassed
or at worst be a nop.
