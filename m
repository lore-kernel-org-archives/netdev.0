From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 01:56:57 +0200
Message-ID: <20080717235657.GB6833@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171627t1dd0ac5bx26535b5e19606835@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:59729 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390AbYGQX5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 19:57:21 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807171627t1dd0ac5bx26535b5e19606835@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > With this config:
> >
> >   http://redhat.com/~mingo/misc/config-Thu_Jul_17_20_24_45_CEST_2008.bad
> >
> 
> It doesn't actually work. The config says
> 
>     # head: 088fcf34
> 
> and I checked out this from the tip tree. But kernel-config still
> complains about unknown config options... What went wrong?

that's ok - i've got some local qa helpers that have config options. 

Things like making SMP bootups more likely in randconfig, adding various 
boot parameters to the bootup via .config methods (so that boot 
parameters can be randomized via make randconfig), etc.

these:

  CONFIG_BOOTPARAM_SUPPORT=y
  CONFIG_BOOTPARAM_NO_HZ_OFF=y
  CONFIG_BOOTPARAM_NMI_WATCHDOG_BIT_0=y
  CONFIG_BOOTPARAM_LAPIC=y
  CONFIG_BOOTPARAM_IDLE_MWAIT=y
  CONFIG_BOOTPARAM_NOPAT=y
  CONFIG_BOOTPARAM_NOTSC=y

are equivalent to adding this to the boot line:

   nohz=off nmi_watchdog=1 lapic idle=mwait nopat notsc

although i dont think they are normally material to netconsole workings.

	Ingo
