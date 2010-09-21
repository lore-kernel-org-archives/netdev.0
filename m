From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 21 Sep 2010 16:47:45 -0400
Message-ID: <AANLkTinRM3_kBc5S3wV=_S6P8+x7A43kz0qSYbixJYnq@mail.gmail.com>
References: <cover.1281956490.git.richard.cochran@omicron.at>
 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
 <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
 <20100817085324.GB3330@riccoc20.at.omicron.at> <1282090963.1734.97.camel@localhost>
 <20100818071942.GA4096@riccoc20.at.omicron.at> <1282176776.2865.100.camel@localhost.localdomain>
 <20100819055518.GA4084@riccoc20.at.omicron.at> <1282594125.3111.344.camel@localhost.localdomain>
 <20100827123849.GC11657@riccoc20.at.omicron.at> <1282948239.2268.155.camel@jstultz-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>
To: John Stultz <johnstul@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282948239.2268.155.camel@jstultz-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 18:30, John Stultz <johnstul@us.ibm.com> wrote:
> On one side, there is the view that the kernel should abstract and hide
> the hardware details to increase app portability. And the other is that
> the raw hardware details should be exposed, so the OS stays out of the
> way.
>
> Neither of these views are always right. Ideally we can come up with a
> abstracted way to provide the hardware data needed that's generic enough
> that applications don't have to be changed when moving between hardware
> or configurations.
>
> The posix clock id interface is frustrating because the flat static
> enumeration is really limiting.
>
> I wonder if a dynamic enumeration for posix clocks would be possibly a
> way to go?

Well how about something much more straightforward:

#define CLOCK_FD 0x80000000
fd = open("/dev/clocks/some_clock_name", O_RDONLY);
clock_gettime(CLOCK_FD | fd, &ts);

This would provide all of the standard character-device semantics that
everyone is accustomed to, and furthermore you could allow non-root
users to manage specific clocks using just DAC permission bits.

You'd still probably need to add a clock_adjtimex() syscall, but it
could easily fail with EINVAL for software or per-thread clocks, but
that seems like it would nicely abstract the hardware without forcing
a numeric address space.

Cheers,
Kyle Moffett
