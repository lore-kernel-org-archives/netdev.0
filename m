From: Simon Horman <horms@verge.net.au>
Subject: Re: Kconfig warnings on latest GIT
Date: Mon, 14 May 2007 10:32:32 +0900
Message-ID: <20070514013230.GJ3588@verge.net.au>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <1178811570.3806.18.camel@johannes.berg> <20070511012216.GB10715@verge.net.au> <1178883937.8896.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Ralf Baechle <ralf@linux-mips.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:52696 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757737AbXENBcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 21:32:39 -0400
Content-Disposition: inline
In-Reply-To: <1178883937.8896.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 01:45:37PM +0200, Johannes Berg wrote:
> On Fri, 2007-05-11 at 10:22 +0900, Simon Horman wrote:
> 
> > Actually, it was with ARCH=ia64. I have a feeling that you can get
> > it to show up quite easily with anything other than ARCH=powerpc.
> 
> Ick, I didn't know that drivers/macintosh was now included for all
> arches! Hmm. That's a bit of a problem.
> 
> I could do
> 
> config PMAC_APM_EMU
>         tristate "APM emulation"
>         depends on SYS_SUPPORTS_APM_EMULATION
>         select APM_EMULATION
>         depends on ADB_PMU && PM
> 
> and then
> 
> config SYS_SUPPORTS_APM_EMULATION
> 	bool
> 	default y
> 	depends on PPC_PMAC
> 
> I'll have to run test that.

Hi Johannes,

I don't think that this is quite right, or at least it isn't quite the
same as before. I think that was is below will toggle
SYS_SUPPORTS_APM_EMULATION when PMAC_APM_EMU is selected,
which I think is what you want. Is it also neccessary to
add a dependancy on PPC_PMAC to PMAC_APM_EMU ?

config PMAC_APM_EMU
	tristate "APM emulation"
	select APM_EMULATION
	depends on ADB_PMU && PM

config SYS_SUPPORTS_APM_EMULATION
	bool
	default y if PMAC_APM_EMU

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

