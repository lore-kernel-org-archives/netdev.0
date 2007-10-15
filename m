From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Mon, 15 Oct 2007 18:03:20 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl>
References: <20071015125301.GC3015@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:39049 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183AbXJORD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 13:03:27 -0400
In-Reply-To: <20071015125301.GC3015@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007, Jarek Poplawski wrote:

> Could you explain why cancel_work_sync() is better here than
> flush_scheduled_work() wrt. rtnl_lock()?

 Well, this is actually the bit that made cancel_work_sync() be written in 
the first place.  The short story is the netlink lock is most probably 
held at this point (depending on the usage of phy_disconnect()) and there 
is also an event waiting in the queue that requires the lock, so if 
flush_scheduled_work() is called here a deadlock will happen.

 Let me find a reference for a longer story...:

http://www.linux-mips.org/cgi-bin/mesg.cgi?a=linux-mips&i=Pine.LNX.4.64N.0610031509380.4642%40blysk.ds.pg.gda.pl

and then discussed again:

http://www.uwsg.indiana.edu/hypermail/linux/kernel/0612.0/0593.html

  Maciej
