From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][AX25] ax25_route: make ax25_route_lock BH safe
Date: Mon, 11 Feb 2008 21:26:59 -0800 (PST)
Message-ID: <20080211.212659.228544422.davem@davemloft.net>
References: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn>
	<20080211124251.GB3597@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jann@gmx.de, f6bvp@free.fr, ralf@linux-mips.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752299AbYBLF01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:26:27 -0500
In-Reply-To: <20080211124251.GB3597@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 11 Feb 2008 12:42:51 +0000

> [AX25] ax25_route: make ax25_route_lock BH safe
> 
> > =================================
> > [ INFO: inconsistent lock state ]
> > 2.6.24-dg8ngn-p02 #1
> > ---------------------------------
> > inconsistent {softirq-on-W} -> {in-softirq-R} usage.
> > linuxnet/3046 [HC0[0]:SC1[2]:HE1:SE0] takes:
> >  (ax25_route_lock){--.+}, at: [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
> > {softirq-on-W} state was registered at:
> ...
> 
> This lockdep report shows that ax25_route_lock is taken for reading in
> softirq context, and for writing in process context with BHs enabled.
> So, to make this safe, all write_locks in ax25_route.c are changed to
> _bh versions.
> 
> 
> Reported-by: Jann Traschewski <jann@gmx.de>,
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot Jarek.
