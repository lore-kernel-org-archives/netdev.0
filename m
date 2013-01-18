From: Pedro Alves <palves@redhat.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Fri, 18 Jan 2013 10:44:53 +0000
Message-ID: <50F927A5.5060409@redhat.com>
References: <201301161205.04502.vapier@gentoo.org> <50F75EA7.4060309@systemhalted.org> <20130116.221538.1756411165313441486.davem@davemloft.net> <201301172320.19905.vapier@gentoo.org> <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, David Miller <davem@davemloft.net>,
        libc-alpha@sourceware.org, bhutchings@solarflare.com,
        yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
        eblake@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, libvirt-list@redhat.com, tgraf@suug.ch,
        schwab@suse.de
To: "Carlos O'Donell" <carlos@systemhalted.org>
Return-path: <libc-alpha-return-36411-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On 01/18/2013 04:22 AM, Carlos O'Donell wrote:
> On Thu, Jan 17, 2013 at 11:20 PM, Mike Frysinger <vapier@gentoo.org> wrote:
>> On Wednesday 16 January 2013 22:15:38 David Miller wrote:
>>> From: Carlos O'Donell <carlos@systemhalted.org>
>>> Date: Wed, 16 Jan 2013 21:15:03 -0500
>>>
>>>> +/* If a glibc-based userspace has already included in.h, then we will
>>>> not + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq.
>>>> The + * ABI used by the kernel and by glibc match exactly. Neither the
>>>> kernel + * nor glibc should break this ABI without coordination.
>>>> + */
>>>> +#ifndef _NETINET_IN_H
>>>> +
>>>
>>> I think we should shoot for a non-glibc-centric solution.
>>>
>>> I can't imagine that other libc's won't have the same exact problem
>>> with their netinet/in.h conflicting with the kernel's, redefining
>>> structures like in6_addr, that we'd want to provide a protection
>>> scheme for here as well.
>>
>> yes, the kernel's use of __GLIBC__ in exported headers has already caused
>> problems in the past.  fortunately, it's been reduced down to just one case
>> now (stat.h).  let's not balloon it back up.
>> -mike
> 
> I also see coda.h has grown a __GLIBC__ usage.
> 
> In the next revision of the patch I created a single libc-compat.h header
> which encompasses the logic for any libc that wants to coordinate with
> the kernel headers.


> It's simple enough to move all of the __GLIBC__ uses into libc-compat.h,
> then you control userspace libc coordination from one file.

How about just deciding on a single macro/symbol both the
kernel and libc (any libc that needs this) define?  Something
like both the kernel and userland doing:

#ifndef __IPV6_BITS_DEFINED
#define __IPV6_BITS_DEFINED
...
define in6_addr, sockaddr_in6, ipv6_mreq, whatnot
#endif

So whichever the application includes first, wins.
Too naive?  I didn't see this option being discarded, so
not sure it was considered.

-- 
Pedro Alves
