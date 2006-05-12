From: Paul Mackerras <paulus@samba.org>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Fri, 12 May 2006 11:59:10 +1000
Message-ID: <17507.60398.845863.783477@cargo.ozlabs.ibm.com>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<1147326683.29448.80.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:23954 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1750799AbWELB7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 21:59:21 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1147326683.29448.80.camel@tahini.andynet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay writes:

> How does the serial driver know it has to call ppp_asynctty_wakeup()?

The serial driver is supposed to call the line discipline's wakeup
function when it has room in the output buffer and the
TTY_DO_WRITE_WAKEUP bit is set in tty->flags.  When the serial port is
set to the ppp line discipline, then it uses the functions defined in
the ppp_ldisc structure in drivers/net/ppp_async.c, and the
write_wakeup field in that structure points to ppp_asynctty_wakeup.

> There were a bunch of changes to the serial drivers between 2.6.15 and
> 2.6.16, maybe that's where this problem was introduced. Do we know which
> serial driver is involved in the original report?

Apparently it's the pty driver.

Paul.
