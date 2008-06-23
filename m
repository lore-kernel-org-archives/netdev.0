From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 22:40:51 +0300
Message-ID: <20080623194051.GA1885@cs181140183.pp.htv.fi>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi> <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:36119 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246AbYFWTmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 15:42:47 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008 at 11:31:30AM -0700, Waskiewicz Jr, Peter P wrote:
> >Commit d62733c8e437fdb58325617c4b3331769ba82d70
> >([SCHED]: Qdisc changes and sch_rr added for multiqueue)
> >added a NET_SCH_RR option that was unused since the code
> >went unconditionally into sch_prio.
> 
> I don't agree we should remove this option, purely for the fact that
> there isn't any way a user would know the qdisc existed without reading
> the code.

Most users of the kernel will anyway use a distribution kernel, and 
therefore never see it.

If the problem is a lack of any user documentation then kconfig is wrong 
place to attack that.

> I'd rather see a change to sch_prio.c to correctly wrap the
> RR code, which I should have done in the first place.  My hurdle is when
> the module is selected, NET_SCH_RR isn't defined to be used as an #ifdef
> check in the code. Only when it's selected to be built-in is the symbol
> defined.  If I can get around that, I'll generate a patch to properly
> wrap sch_prio.c code.  I know I'm missing something silly, so any
> guidance is appreciated.

In this case NET_SCH_RR is not a module but a feature inside 
NET_SCH_PRIO, and that can be expressed as follows:

config NET_SCH_RR
        bool "Multi Band Round Robin Queuing (RR)"
        depends on NET_SCH_PRIO

But I doubt making these #ifdef's makes much sense.

IMHO the best you can do is to add a note about RR to the NET_SCH_PRIO 
help text.

> -PJ Waskiewicz

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

