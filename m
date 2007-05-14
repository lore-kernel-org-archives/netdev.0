From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: Kconfig warnings on latest GIT
Date: Mon, 14 May 2007 09:24:43 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0705140923470.24559@gate.crashing.org>
References: <200705080004.14570.ismail@pardus.org.tr>
 <20070508143127.38fafa3c.kim.phillips@freescale.com>  <4640D988.1040504@freescale.com>
 <20070510051042.GA16812@verge.net.au>  <1178811570.3806.18.camel@johannes.berg>
  <20070511012216.GB10715@verge.net.au>  <1178883937.8896.11.camel@johannes.berg>
  <20070514013230.GJ3588@verge.net.au> <1179147311.2647.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>,
	Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?ISO-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Ralf Baechle <ralf@linux-mips.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:32861 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241AbXENO2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 10:28:03 -0400
In-Reply-To: <1179147311.2647.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 May 2007, Johannes Berg wrote:

> Simon,
>
> > I don't think that this is quite right, or at least it isn't quite the
> > same as before.
>
> Yeah, I think you're right.
>
> >  I think that was is below will toggle
> > SYS_SUPPORTS_APM_EMULATION when PMAC_APM_EMU is selected,
> > which I think is what you want. Is it also neccessary to
> > add a dependancy on PPC_PMAC to PMAC_APM_EMU ?
>
> No, it depends on ADB_PMU which depends on PPC_PMAC.
>
> > config PMAC_APM_EMU
> > 	tristate "APM emulation"
> > 	select APM_EMULATION
> > 	depends on ADB_PMU && PM
> >
> > config SYS_SUPPORTS_APM_EMULATION
> > 	bool
> > 	default y if PMAC_APM_EMU
>
> I still have to try it, I haven't been yet seen Kumar's fix that he said
> he'd done.
>
> johannes

this was my fix which looks pretty much the same.

- k

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index ccc5410..af70799 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -118,6 +118,7 @@ config GENERIC_BUG
 	depends on BUG

 config SYS_SUPPORTS_APM_EMULATION
+	default y if PMAC_APM_EMU
 	bool

 config DEFAULT_UIMAGE
diff --git a/drivers/macintosh/Kconfig b/drivers/macintosh/Kconfig
index 58926da..f44c94a 100644
--- a/drivers/macintosh/Kconfig
+++ b/drivers/macintosh/Kconfig
@@ -113,7 +113,6 @@ config PMAC_SMU

 config PMAC_APM_EMU
 	tristate "APM emulation"
-	select SYS_SUPPORTS_APM_EMULATION
 	select APM_EMULATION
 	depends on ADB_PMU && PM

