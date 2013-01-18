From: "Carlos O'Donell" <carlos@systemhalted.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 23:22:26 -0500
Message-ID: <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com>
References: <201301161205.04502.vapier@gentoo.org>
	<50F75EA7.4060309@systemhalted.org>
	<20130116.221538.1756411165313441486.davem@davemloft.net>
	<201301172320.19905.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, yoshfuji@linux-ipv6.org,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201301172320.19905.vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 17, 2013 at 11:20 PM, Mike Frysinger <vapier@gentoo.org> wrote:
> On Wednesday 16 January 2013 22:15:38 David Miller wrote:
>> From: Carlos O'Donell <carlos@systemhalted.org>
>> Date: Wed, 16 Jan 2013 21:15:03 -0500
>>
>> > +/* If a glibc-based userspace has already included in.h, then we will
>> > not + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq.
>> > The + * ABI used by the kernel and by glibc match exactly. Neither the
>> > kernel + * nor glibc should break this ABI without coordination.
>> > + */
>> > +#ifndef _NETINET_IN_H
>> > +
>>
>> I think we should shoot for a non-glibc-centric solution.
>>
>> I can't imagine that other libc's won't have the same exact problem
>> with their netinet/in.h conflicting with the kernel's, redefining
>> structures like in6_addr, that we'd want to provide a protection
>> scheme for here as well.
>
> yes, the kernel's use of __GLIBC__ in exported headers has already caused
> problems in the past.  fortunately, it's been reduced down to just one case
> now (stat.h).  let's not balloon it back up.
> -mike

I also see coda.h has grown a __GLIBC__ usage.

In the next revision of the patch I created a single libc-compat.h header
which encompasses the logic for any libc that wants to coordinate with
the kernel headers.

It's simple enough to move all of the __GLIBC__ uses into libc-compat.h,
then you control userspace libc coordination from one file.

Cheers,
Carlos.
