From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Fri, 6 Nov 2015 11:16:52 -0800
Message-ID: <20151106191652.GA4046@roeck-us.net>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
 <4129407.LpDXnpSZOL@wuerfel>
 <5627C549.9080600@roeck-us.net>
 <5243548.YbVhhU6W8t@wuerfel>
 <20151021215320.GB23371@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021215320.GB23371@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd,

On Wed, Oct 21, 2015 at 02:53:20PM -0700, Guenter Roeck wrote:
> On Wed, Oct 21, 2015 at 09:11:53PM +0200, Arnd Bergmann wrote:
> > On Wednesday 21 October 2015 10:03:05 Guenter Roeck wrote:
> > > >
> > > > Something like this?
> > > >
> > > > static inline u64 of_translate_address(struct device_node *np, const __be32 *addr)
> > > > {
> > > > #if defined(CONFIG_SPARC) || defined(CONFIG_M68K)
> > > >       int pna = of_n_addr_cells(np);
> > > >       u64 ret = be32_to_cpu(addr[pna - 1]);
> > > >
> > > >       if (pna > 1)
> > > >               ret += (u64)be32_to_cpu(addr[pna - 2]) << 32;
> > > >
> > > >       return ret;
> > > 
> > > That suggests that sparc would need a translation after all, which
> > > seems to contradict what David said earlier.
> > 
> > No, not a translation: the value is used without any offset that
> > factors in the location of the bus, the above is just the shortest
> > possible way to read the 64-bit number from a big-endian property
> > of variable length.
> > 
> Out of my realm .. David would have to comment on that.
> 
> > > Anyway, if it gets that complicated, I think we should stick with
> > > just returning OF_BAD_ADDR. The above really suggests the need for
> > > an architecture specific solution.
> > 
> > Probably no harm in this really: the far more common
> > of_address_to_resource() and of_iomap() helpers are equally
> > broken on SPARC and we just return a runtime error for those
> > as well without CONFIG_OF_ADDRESS rather than breaking the build.
> > 
> Agreed. Given this, returning OF_BAD_ADDR sounds like a better choice.
> 
Arnd,

do you know if a fix for this problem is pending in some branch ?
Mainline sparc builds are now affected.

Thanks,
Guenter
