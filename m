From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Tue, 17 Oct 2006 13:18:12 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610171306560.27348@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
 <20061005234310.6c8042b5.akpm@osdl.org> <Pine.LNX.4.64N.0610061152340.22053@blysk.ds.pg.gda.pl>
 <20061006080323.185f2b58.akpm@osdl.org> <Pine.LNX.4.64N.0610161442010.28780@blysk.ds.pg.gda.pl>
 <20061016120653.9a70135d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:23813 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1750741AbWJQMSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 08:18:16 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061016120653.9a70135d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Oct 2006, Andrew Morton wrote:

> Vaguely.  Why doesn't it deadlock if !current_is_keventd()?  I mean,
> whether or not the caller is keventd, the flush_scheduled_work() caller
> will still be dependent upon rtnl_lock() being acquirable.

 This !current_is_keventd() condition is just what it is, i.e. a check 
whether phy_stop_interrupts() has been scheduled through keventd or not.  
If it has, then flush_scheduled_work() cannot be called; it is not needed 
anyway.  Otherwise phy_stop_interrupts() has to make sure no deferred 
calls to phy_change() will be made once it has finished.

 In all cases the assumption is the caller has made sure rtnl_lock() is 
not held at the time phy_stop_interrupts() is called.  That's the very 
reason for scheduling phy_disconnect() (and hence phy_stop_interrupts()) 
through keventd.

  Maciej
