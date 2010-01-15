From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 15 Jan 2010 00:43:05 -0800 (PST)
Message-ID: <20100115.004305.73783675.davem@davemloft.net>
References: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56426
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755550Ab0AOImz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:42:55 -0500
In-Reply-To: <20100115053117.31513.82775.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 15 Jan 2010 11:01:17 +0530

> A developer had complained of getting lots of warnings:
> 
> "eth16 selects TX queue 98, but real number of TX queues is 64"
> 
> http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02200.html
> 
> As there was no follow up on that bug, I am submitting this
> patch assuming that the other return points will not return
> invalid txq's, and also that this fixes the bug (not tested).
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Guys I'm really sick of seeing this bug.  Stop assuming that the
platform has limitations that platforms you happen to work on have.

NR_CPUS can be 4096, so you must assume everywhere that
smp_processor_id() can return just about any number.

Modulo the damn thing, or similar.

Don't use tables or crap like that.  We do like Krishna's scheme
in net/core/dev.c:skb_tx_hash(), and that's what we should do
here too.

Krishna's patch is therefore correct, and I don't want to hear
anything about "tables", unless you're going to add "tables"
to net/core/dev.c :-)

