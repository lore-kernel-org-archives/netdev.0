From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH 3/4] uapi glibc compat: Do not check for __USE_MISC
Date: Thu, 16 Mar 2017 10:26:44 +0200
Message-ID: <20170316082644.GD8672@lakka.kapsi.fi>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-4-hauke@hauke-m.de>
 <1489651152.4195.192.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489651152.4195.192.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 07:59:12AM +0000, David Woodhouse wrote:
> On Sun, 2017-03-12 at 23:00 +0100, Hauke Mehrtens wrote:
> > __USE_MISC is glibc specific and not available in musl libc. Only do
> > this check when glibc is used. This fixes a problem with musl libc.
> > ...
> > -/* Coordinate with glibc net/if.h header. */
> > -#if defined(_NET_IF_H) && defined(__USE_MISC)
> > +/* Coordinate with libc net/if.h header. */
> > +#if defined(_NET_IF_H) && (!defined(__GLIBC__) || defined(__USE_MISC))
> 
> I *really* don't like building up a plethora of knowledge about
> specific libc implementations in the kernel. As a general rule, if we
> have *anything* that depends on __GLIBC__ then we are Doing It Wrong™.

Kernel does not depend on glibc but uapi headers check for some defintions
so that userspace code can include both libc and kernel header files
without compiler errors.

This interface between kernel and libc header files is messy due to long
history of copying header files from kernel to libc implementations etc
and thus this kind of ifdef magic with in depth knowledge of various
libc's defintions is currently unavoidable.

-Mikko
