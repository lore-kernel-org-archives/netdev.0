From: josh@joshtriplett.org
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Mon, 29 Jun 2015 09:50:00 -0700
Message-ID: <20150629165000.GA1483@cloud>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
 <20150629161355.GS15805@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, pmladek@suse.cz,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:46808 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbbF2QuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 12:50:05 -0400
Content-Disposition: inline
In-Reply-To: <20150629161355.GS15805@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2015 at 12:13:55PM -0400, Tejun Heo wrote:
> On Mon, Jun 29, 2015 at 06:11:40PM +0200, Geert Uytterhoeven wrote:
> > On Mon, Jun 29, 2015 at 5:49 PM, Tejun Heo <tj@kernel.org> wrote:
> > > On Mon, Jun 29, 2015 at 05:47:49PM +0200, Geert Uytterhoeven wrote:
> > >> > netconsole itself is optional & modular.  I'm not sure making further
> > >> > splits is called for, especially given the use cases.
> > >>
> > >> It could be a hidden option, selected by its users (e.g. netconsole).
> > >
> > > Hmmm... what do you mean?
> > 
> > init/Kconfig:
> > 
> >         config PRINTK_EXT_LOG
> >                 bool
> > 
> > drivers/net/Kconfig:
> > 
> >         config NETCONSOLE
> >                 tristate "Network console logging support"
> >                 select PRINTK_EXT_LOG
> > 
> > kernel/printk/printk.c:
> > 
> >         void console_unlock(void)
> >         {
> > #ifdef CONFIG_PRINTK_EXT_LOG
> >                 static char ext_text[CONSOLE_EXT_LOG_MAX];
> > #endif
> 
> OIC, hmmm... yeah, I think doing it on-demand would be better but will
> try to find out which way is better.

Allocating the buffer dynamically is fine, but in that case the code to
do so should ideally be compiled out.  Since printk is used by almost
*all* kernels, while netconsole is not, it's more critical to avoid
allowing printk's size to balloon.

- Josh Triplett
