From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tty: Flags should be accessed via the foo_bit
 interfaces
Date: Thu, 04 Dec 2008 15:04:43 -0800 (PST)
Message-ID: <20081204.150443.30081008.davem@davemloft.net>
References: <20081204154030.27980.82380.stgit@localhost.localdomain>
	<87a5b0800812040750p6231b0c9s2f664345b23596f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: will.newton@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751768AbYLDXEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:04:42 -0500
In-Reply-To: <87a5b0800812040750p6231b0c9s2f664345b23596f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Will Newton" <will.newton@gmail.com>
Date: Thu, 4 Dec 2008 15:50:29 +0000

> On Thu, Dec 4, 2008 at 3:41 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > @@ -515,10 +515,9 @@ sl_close(struct net_device *dev)
> >        struct slip *sl = netdev_priv(dev);
> >
> >        spin_lock_bh(&sl->lock);
> > -       if (sl->tty) {
> > +       if (sl->tty)
> > +               clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
> >                /* TTY discipline is running. */
> > -               sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
> > -       }
> 
> The indentation of the comment looks like it might be wrong here.

Indeed.  In fact it's now transposed with the operation it describes,
and thus the braces should probably be preserved here as well.

Alan could you please fix this up?

Thanks!
