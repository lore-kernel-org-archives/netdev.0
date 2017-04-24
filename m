From: Tony Lindgren <tony@atomide.com>
Subject: Re: cpsw regression in mainline with "cpsw/netcp: cpts depends on
 posix_timers"
Date: Mon, 24 Apr 2017 10:44:13 -0700
Message-ID: <20170424174413.GD3780@atomide.com>
References: <20170424165104.GC3780@atomide.com>
 <CAK8P3a3kvMubq5Mtu3XKnityAgRv5R35dMtTX=BO8Qv_iX9=VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        Networking <netdev@vger.kernel.org>, linux-omap@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:45208 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1171992AbdDXRoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:44:16 -0400
Content-Disposition: inline
In-Reply-To: <CAK8P3a3kvMubq5Mtu3XKnityAgRv5R35dMtTX=BO8Qv_iX9=VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann <arnd@arndb.de> [170424 10:38]:
> On Mon, Apr 24, 2017 at 6:51 PM, Tony Lindgren <tony@atomide.com> wrote:
> > Hi,
> >
> > Looks like commit 07fef3623407 ("cpsw/netcp: cpts depends on posix_timers")
> > in mainline started triggering the following oops at least on j5eco-evm.
> >
> > Adding CONFIG_PTP_1588_CLOCK to .config solves it, but the oops hints
> > something is wrong with the dependencies.. CONFIG_TI_CPTS defaults to N
> > and not selecting it causes the oops.
> >
> > Any ideas what's needed to properly fix this?
> 
> Does your configuration have POSIX_TIMERS enabled? If not, then CPTS
> is now also disabled. There are two issues here that we need to solve:
> 
> a) find out why POSIX_TIMERS got disabled, and make sure it's always
>     turned on for normal users

$ make omap2plus_defconfig
...
CONFIG_POSIX_TIMERS=y
# CONFIG_PTP_1588_CLOCK is not set

So CONFIG_TI_CPTS is unselectable.

> b) find out what's wrong with the driver when CPTS is disabled. This would
>     be an existing problem that you just never saw because CPTS was
>     always enabled so far.

See a) above, yes seems there are two problems here.

Regards,

Tony
