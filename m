From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
 cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 19:40:17 +0100
Message-ID: <20091217184017.GA2578@ami.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
 <20091217074930.GA6779@ff.dom.local>
 <20091217133644.GD8654@ff.dom.local>
 <1261060259.10356.112.camel@johannes.local>
 <11218.1261066373@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:62699 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935665AbZLQSkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 13:40:47 -0500
Received: by fxm21 with SMTP id 21so2167072fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 10:40:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <11218.1261066373@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 08:12:53AM -0800, Jay Vosburgh wrote:
> 	There's already logic in the monitors (bond_mii_monitor, et al)
> to check a sentinel (kill_timers) and do nothing (not acquire rtnl) and
> return.

Btw, this check should be repeated if bond->lock is given back and
re-acquired. I can't see these kill_timers used in bond_sysfs.c though.

> 	What exactly is the nature of the race that doing cancel..sync
> is fixing?  The bond_close function sets kill_timers prior to calling
> the cancel functions, so the monitor function might run once, but it
> should do nothing.

I guess there is a problem with destructions, but I hope Mikhail will
give more details.

Jarek P.
