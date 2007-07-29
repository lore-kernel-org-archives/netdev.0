From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] fix endianness bug in l2cap_sock_listen()
Date: Sun, 29 Jul 2007 00:16:00 -0700 (PDT)
Message-ID: <20070729.001600.74751290.davem@davemloft.net>
References: <E1IEPNS-0005RS-7o@ZenIV.linux.org.uk>
	<1185547278.13228.15.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760218AbXG2HQS@vger.kernel.org>
In-Reply-To: <1185547278.13228.15.camel@violet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Fri, 27 Jul 2007 16:41:18 +0200

> > We loop through psm values, calling __l2cap_get_sock_by_addr(psm, ...)
> > until we get NULL; then we set ->psm of our socket to htobs(psm).
> > IOW, we find unused psm value and put it into our socket.  So far, so
> > good, but...  __l2cap_get_sock_by_addr() compares its argument with
> > ->psm of sockets.  IOW, the entire thing works correctly only on
> > little-endian.  On big-endian we'll get "no socket with such psm"
> > on the first iteration, since we won't find a socket with ->psm == 0x1001.
> > We will happily conclude that 0x1001 is unused and slap htobs(0x1001)
> > (i.e. 0x110) into ->psm of our socket.  Of course, the next time around
> > the same thing will repeat and we'll just get a fsckload of sockets
> > with the same ->psm assigned.
> > 
> > Fix: pass htobs(psm) to __l2cap_get_sock_by_addr() there.  All other
> > callers are already passing little-endian values and all places that
> > store something in ->psm are storing little-endian.
> > 
> > Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Applied.

> Dave, all four patches are good and should go in sooner than later. If
> you want me to put them into my tree first, then I can do that or you
> can apply them directly. You choice.

I'll take care of these, thanks.
