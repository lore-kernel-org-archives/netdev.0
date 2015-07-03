From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 v4.2-rc1] printk: make extended printk support
 conditional on netconsole
Date: Fri, 3 Jul 2015 11:25:55 -0400
Message-ID: <20150703152555.GA5273@mtj.duckdns.org>
References: <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
 <20150629161355.GS15805@mtj.duckdns.org>
 <20150629233140.GA7711@mtj.duckdns.org>
 <20150702162141.GC30677@mtj.duckdns.org>
 <20150703140352.GD32664@pathway.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>,
	geert@linux-m68k.org
To: Petr Mladek <pmladek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150703140352.GD32664@pathway.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 03, 2015 at 04:07:34PM +0200, Petr Mladek wrote:
> > @@ -2561,9 +2591,11 @@ void register_console(struct console *newcon)
> >  		console_drivers->next = newcon;
> >  	}
> >  
> > -	if (newcon->flags & CON_EXTENDED)
> > -		if (!nr_ext_console_drivers++)
> > +	if (newcon->flags & CON_EXTENDED) {
> > +		if (!nr_ext_console_drivers)
> >  			pr_info("printk: continuation disabled due to ext consoles, expect more fragments in /dev/kmsg\n");
> 
> I would move the check and the message into
> inc_nr_ext_console_drivers() when CONFIG_PRINTK_CON_EXTENDED is
> defined. It does not make sense if we do not increment the counter.

It doesn't make any difference as it gets compiled out anyway but yeah
moving it into the inc function makes more sense.  Updating the patch.

Thanks.

-- 
tejun
