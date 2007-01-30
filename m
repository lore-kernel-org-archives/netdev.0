From: David Miller <davem@davemloft.net>
Subject: Re: buggy IFB driver change
Date: Tue, 30 Jan 2007 14:12:40 -0800 (PST)
Message-ID: <20070130.141240.97296236.davem@davemloft.net>
References: <20070130.131246.71091370.davem@davemloft.net>
	<45BFBE1B.2040508@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl, akpm@osdl.org,
	torvalds@linux-foundation.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751572AbXA3WMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 17:12:41 -0500
In-Reply-To: <45BFBE1B.2040508@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 30 Jan 2007 16:52:27 -0500

> David Miller wrote:
> > Jeff, please revert: 0c0b3ae68ec93b1db5c637d294647d1cca0df763
> > 
> > It's wrong.  We had a lengthy analysis of this piece of code
> > several months ago, and it is correct.
> > 
> > Consider, if we run the loop and we get an error
> > the following happens:
> > 
> > 1) attempt of ifb_init_one(i) fails, therefore we should
> >    not try to "ifb_free_one()" on "i" since it failed
> > 2) the loop iteration first increments "i", then it
> >    check for error
> > 
> > Therefore we must decrement "i" twice before the first
> > free during the cleanup.  One to "undo" the for() loop
> > increment, and one to "skip" the ifb_init_one() case which
> > failed.
> > 
> > commit 0c0b3ae68ec93b1db5c637d294647d1cca0df763
> > Author: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
> Andrew and I both missed that thread, sorry.
> 
> I'm about to crash, can you or Linus handle the correction?

Sure.
