From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Mon, 29 Jun 2015 12:13:55 -0400
Message-ID: <20150629161355.GS15805@mtj.duckdns.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmladek@suse.cz, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 29, 2015 at 06:11:40PM +0200, Geert Uytterhoeven wrote:
> On Mon, Jun 29, 2015 at 5:49 PM, Tejun Heo <tj@kernel.org> wrote:
> > On Mon, Jun 29, 2015 at 05:47:49PM +0200, Geert Uytterhoeven wrote:
> >> > netconsole itself is optional & modular.  I'm not sure making further
> >> > splits is called for, especially given the use cases.
> >>
> >> It could be a hidden option, selected by its users (e.g. netconsole).
> >
> > Hmmm... what do you mean?
> 
> init/Kconfig:
> 
>         config PRINTK_EXT_LOG
>                 bool
> 
> drivers/net/Kconfig:
> 
>         config NETCONSOLE
>                 tristate "Network console logging support"
>                 select PRINTK_EXT_LOG
> 
> kernel/printk/printk.c:
> 
>         void console_unlock(void)
>         {
> #ifdef CONFIG_PRINTK_EXT_LOG
>                 static char ext_text[CONSOLE_EXT_LOG_MAX];
> #endif

OIC, hmmm... yeah, I think doing it on-demand would be better but will
try to find out which way is better.

Thanks!

-- 
tejun
