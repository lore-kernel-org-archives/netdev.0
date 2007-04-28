From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/3] ne: Add platform_driver
Date: Sun, 29 Apr 2007 01:40:26 +0900 (JST)
Message-ID: <20070429.014026.25926525.anemo@mba.ocn.ne.jp>
References: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
	<20070428005727.6414a24e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:54349 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965953AbXD1QkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 12:40:25 -0400
In-Reply-To: <20070428005727.6414a24e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 00:57:27 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> > +#else /* MODULE */
> > +module_init(ne_init);
> > +module_exit(ne_exit);
> >  #endif /* MODULE */
> 
> Are we sure about this part?  It is unusual to have special treatment dependent
> upon MODULE.

Yes, it is unusual now, but ne.c has old-fashioned init_module() which
can not be used if it was built into kernel.  Also ne.c depends on
old-style initialization by Space.c.

Rewriting those old-style initialization code could be possible, but
it will involve much more changes and might cause compatibility issue
(if somebody depends on ethN order of built-in drivers).  So I chose
least intrusive way.

---
Atsushi Nemoto
