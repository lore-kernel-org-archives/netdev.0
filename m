From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ndo_get_stats and rtnl_netlink
Date: Mon, 10 Sep 2012 21:15:14 +0200
Message-ID: <1347304514.1234.1993.camel@edumazet-glaptop>
References: <504CB464.6010207@mellanox.com>
	 <1347268189.1234.1301.camel@edumazet-glaptop>
	 <CAJZOPZKKca6Yea=E9reL+x-cfvX0HwsgLAWKzjonmGwutH0MxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shlomo Pongartz <shlomop@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57782 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097Ab2IJTPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:15:21 -0400
Received: by eekc1 with SMTP id c1so1438985eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 12:15:18 -0700 (PDT)
In-Reply-To: <CAJZOPZKKca6Yea=E9reL+x-cfvX0HwsgLAWKzjonmGwutH0MxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 22:10 +0300, Or Gerlitz wrote:
> On Mon, Sep 10, 2012 at 12:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > RTNL locking is not needed to fetch stats, and would be overkill.
> > Each driver has its own way to protect/gather its stats.
> 
> FWIW, again, when dev_get_stats is called from rtnl_fill_ifinfo e.g as
> of invocation
> of "ip link show <interface>, there IS RTNL locking, is that a problem?
> 
> Or.

Why should it be a problem ?

A dev_get_stats() is not allowed to sleep, so its not allowed to use
RTNL by itself.

So caller might use RTNL, we dont care at all.
