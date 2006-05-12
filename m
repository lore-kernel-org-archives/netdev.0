From: Andy Gay <andy@andynet.net>
Subject: Re: [Bugme-new] [Bug 6530] New: MAINLINE
Date: Thu, 11 May 2006 22:12:58 -0400
Message-ID: <1147399978.29448.142.camel@tahini.andynet.net>
References: <200605100920.k4A9KC91018259@fire-2.osdl.org>
	<20060510023357.0d1260ee.akpm@osdl.org>
	<17505.49174.848331.686297@cargo.ozlabs.ibm.com>
	<1147326683.29448.80.camel@tahini.andynet.net>
	<17507.60398.845863.783477@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:24531 "EHLO
	vms040pub.verizon.net") by vger.kernel.org with ESMTP
	id S1750823AbWELCNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 22:13:11 -0400
Received: from andyhp.tranquilitynj.net ([70.21.136.183])
 by vms040.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0IZ400002RHQI332@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 11 May 2006 21:13:03 -0500 (CDT)
In-reply-to: <17507.60398.845863.783477@cargo.ozlabs.ibm.com>
To: Paul Mackerras <paulus@samba.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-12 at 11:59 +1000, Paul Mackerras wrote:
> Andy Gay writes:
> 
> > How does the serial driver know it has to call ppp_asynctty_wakeup()?
> 
> The serial driver is supposed to call the line discipline's wakeup
> function when it has room in the output buffer and the
> TTY_DO_WRITE_WAKEUP bit is set in tty->flags.  When the serial port is
> set to the ppp line discipline, then it uses the functions defined in
> the ppp_ldisc structure in drivers/net/ppp_async.c, and the
> write_wakeup field in that structure points to ppp_asynctty_wakeup.
> 
OK, thanks for the explanation. I'll pay special attention to that stuff
in my driver!

> > There were a bunch of changes to the serial drivers between 2.6.15 and
> > 2.6.16, maybe that's where this problem was introduced. Do we know which
> > serial driver is involved in the original report?
> 
> Apparently it's the pty driver.
> 
So I heard. Hopefully the maintainer of that driver will see this....

> Paul.

