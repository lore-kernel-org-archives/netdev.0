From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] sh_eth Add SH7619 support
Date: Mon, 4 Aug 2008 04:23:35 +0900
Message-ID: <20080803192335.GB4448@linux-sh.org>
References: <878wvhtynu.wl%ysato@users.sourceforge.jp> <29ab51dc0807312048hfa9cd88pb90d1a7520bb3f99@mail.gmail.com> <871w18ycmr.wl%ysato@users.sourceforge.jp> <20080802073021.GA30041@verge.net.au> <87myjv77nm.wl%ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>,
	Jeff Garzik <jeff@garzik.org>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87myjv77nm.wl%ysato@users.sourceforge.jp>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 02, 2008 at 11:34:21AM -0400, Yoshinori Sato wrote:
> At Sat, 2 Aug 2008 17:30:22 +1000,
> Simon Horman wrote:
> > On Fri, Aug 01, 2008 at 11:32:28AM -0400, Yoshinori Sato wrote:
> > > > > +/* CPU endian from/to EDMAC endian */
> > > > > +#if !defined(CONFIG_CPU_SUBTYPE_SH7619)
> > > > > +#define cpu_to_edmac(x) cpu_to_le32(x)
> > > > > +#define edmac_to_cpu(x) le32_to_cpu(x)
> > > > > +#else
> > > > > +#define cpu_to_edmac(x) cpu_to_be32(x)
> > > > > +#define edmac_to_cpu(x) be32_to_cpu(x)
> > > > > +#endif
> > > > > +
> > > > >  #endif
> > > > I think that this depends on an endian not CPU dependence.
> > > 
> > > I agree.
> > > But I'm no idea.
> > > Are you have good idea?
> > 
> > Iwamatsu-san,
> > 
> > what is the difference between CONFIG_CPU_LITTLE_ENDIAN and
> > __LITTLE_ENDIAN__ as used in drivers/net/sh_eth.h ?
> 
> EDMAC endian is no depend CPU endian.
> 
The cleaner thing to do might just be to introduce a config symbol for
specifying whether the EDMAC is in big or little endian mode, depending
on how it's wired up in the CPU. Also, you should use a consistent ifdef
style. In some cases you only check if 7619 is defined and do your corner
cases there, in others (like this one) you check if it is not defined and
push its corner cases further down. The latter of which is very error
prone.

If the EDMAC endianness can be changed within a given subtype (or hooked
up externally), then we also need to making the conversion run-time
configurable, and we can toss the endian hint in the platform data.
