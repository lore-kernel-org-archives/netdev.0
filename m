From: Thiemo Seufer <ths@networkno.de>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Thu, 13 Sep 2007 02:42:46 +0100
Message-ID: <20070913014246.GB15247@networkno.de>
References: <200709080143.12345.technoboy85@gmail.com> <200709080223.00613.technoboy85@gmail.com> <20070912165029.GG4571@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matteo Croce <technoboy85@gmail.com>, linux-mips@linux-mips.org,
	Eugene Konev <ejka@imfi.kspu.ru>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	openwrt-devel@lists.openwrt.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20070912165029.GG4571@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> On Sat, Sep 08, 2007 at 02:23:00AM +0200, Matteo Croce wrote:
[snip]
> > +/* Register definitions */
> > +struct cpmac_control_regs {
> > +	u32 revision;
> > +	u32 control;
> > +	u32 teardown;
> > +	u32 unused;
> > +} __attribute__ ((packed));
> > +
> > +struct cpmac_int_regs {
> > +	u32 stat_raw;
> > +	u32 stat_masked;
> > +	u32 enable;
> > +	u32 clear;
> > +} __attribute__ ((packed));
> > +
> > +struct cpmac_stats {
> > +	u32 good;
> > +	u32 bcast;
> > +	u32 mcast;
> > +	u32 pause;
> > +	u32 crc_error;
> > +	u32 align_error;
> > +	u32 oversized;
> > +	u32 jabber;
> > +	u32 undersized;
> > +	u32 fragment;
> > +	u32 filtered;
> > +	u32 qos_filtered;
> > +	u32 octets;
> > +} __attribute__ ((packed));
> 
> All struct members here are sized such that there is no padding needed, so
> the packed attribute doesn't buy you anything - unless of course the
> entire structure is missaligned but I don't see how that would be possible
> in this driver so the __attribute__ ((packed)) should go - it result in
> somwhat larger and slower code.

FWIW, a modern gcc will warn about such superfluous packed attributes,
that's another reason to remove those.


Thiemo
