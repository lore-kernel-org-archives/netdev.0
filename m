From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Fri, 18 Jan 2013 23:24:10 +0900
Message-ID: <50F95B0A.1090205@linux-ipv6.org>
References: <201301161205.04502.vapier@gentoo.org> <50F75EA7.4060309@systemhalted.org> <20130116.221538.1756411165313441486.davem@davemloft.net> <201301172320.19905.vapier@gentoo.org> <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com> <50F927A5.5060409@redhat.com> <50F94FA6.6070005@systemhalted.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pedro Alves <palves@redhat.com>,
	Mike Frysinger <vapier@gentoo.org>,
	David Miller <davem@davemloft.net>, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, schwab@suse.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Carlos O'Donell <carlos@systemhalted.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F94FA6.6070005@systemhalted.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carlos O'Donell wrote:
> On 01/18/2013 05:44 AM, Pedro Alves wrote:
>> On 01/18/2013 04:22 AM, Carlos O'Donell wrote:
>>> On Thu, Jan 17, 2013 at 11:20 PM, Mike Frysinger <vapier@gentoo.org> wrote:
>>>> On Wednesday 16 January 2013 22:15:38 David Miller wrote:
>>>>> From: Carlos O'Donell <carlos@systemhalted.org>
>>>>> Date: Wed, 16 Jan 2013 21:15:03 -0500
>>>>>
>>>>>> +/* If a glibc-based userspace has already included in.h, then we will
>>>>>> not + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq.
>>>>>> The + * ABI used by the kernel and by glibc match exactly. Neither the
>>>>>> kernel + * nor glibc should break this ABI without coordination.
>>>>>> + */
>>>>>> +#ifndef _NETINET_IN_H
>>>>>> +
>>>>>
>>>>> I think we should shoot for a non-glibc-centric solution.
>>>>>
>>>>> I can't imagine that other libc's won't have the same exact problem
>>>>> with their netinet/in.h conflicting with the kernel's, redefining
>>>>> structures like in6_addr, that we'd want to provide a protection
>>>>> scheme for here as well.
>>>>
>>>> yes, the kernel's use of __GLIBC__ in exported headers has already caused
>>>> problems in the past.  fortunately, it's been reduced down to just one case
>>>> now (stat.h).  let's not balloon it back up.
>>>> -mike
>>>
>>> I also see coda.h has grown a __GLIBC__ usage.
>>>
>>> In the next revision of the patch I created a single libc-compat.h header
>>> which encompasses the logic for any libc that wants to coordinate with
>>> the kernel headers.
>>
>>
>>> It's simple enough to move all of the __GLIBC__ uses into libc-compat.h,
>>> then you control userspace libc coordination from one file.
>>
>> How about just deciding on a single macro/symbol both the
>> kernel and libc (any libc that needs this) define?  Something
>> like both the kernel and userland doing:
>> 
>> #ifndef __IPV6_BITS_DEFINED
>> #define __IPV6_BITS_DEFINED
>> ...
>> define in6_addr, sockaddr_in6, ipv6_mreq, whatnot
>> #endif

Hmm, how should we handle future structs/enums then?
For example, if I want to have in6_flowlabel_req{} defined in
glibc, what should we do?

We probably want to have __LIBC_HAS_STRUCT_IN6_FLOWLABEL_REQ
defined.

--yoshfuji
