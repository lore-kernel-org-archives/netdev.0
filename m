From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Mon, 19 Feb 2007 22:08:29 +0100
Message-ID: <20070219210829.GA13522@electric-eye.fr.zoreil.com>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com> <20070216075936.GB1599@ff.dom.local> <20070216202034.GA10353@electric-eye.fr.zoreil.com> <20070219120500.GB2190@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58471 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932687AbXBSVKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 16:10:03 -0500
Content-Disposition: inline
In-Reply-To: <20070219120500.GB2190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: list trimmed.

Jarek Poplawski <jarkao2@o2.pl> :
> On Fri, Feb 16, 2007 at 09:20:34PM +0100, Francois Romieu wrote:
[...]
> > Btw, the thread runs every 3*HZ at most.
> 
> You are right (mostly)! But I think rtnl_lock is special
> and should be spared (even this 3*HZ) and here it's used
> for some mainly internal purpose (close synchronization).
> And it looks like mainly for this internal reason holding
> of rtnl_lock is increased. And because rtnl_lock is quite
> popular you have to take into consideration that after
> this 3*HZ it could spend some time waiting for the lock.
> So, maybe it would be nicer to check this netif_running
> twice (after rtnl_lock where needed), but maybe it's a
> mater of taste only, and yours is better, as well.

The region protected by RTNL has been widened to include a tx_timeout
handler. It is supposed to handle an occasional error, something that
should not even happen at 3*HZ. Optimizing it is useless, especially
on an high-end performer like the 8139.

> (Btw. I didn't verify this, but I hope you checked that
> places not under rtnl_lock before the patch are safe from
> some locking problems now.)

I did. It is not a reason to trust the patch though.

-- 
Ueimor
