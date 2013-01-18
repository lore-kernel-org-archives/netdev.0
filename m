From: Pedro Alves <palves@redhat.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Fri, 18 Jan 2013 14:36:35 +0000
Message-ID: <50F95DF3.7080602@redhat.com>
References: <201301161205.04502.vapier@gentoo.org> <50F75EA7.4060309@systemhalted.org> <20130116.221538.1756411165313441486.davem@davemloft.net> <201301172320.19905.vapier@gentoo.org> <CAE2sS1jMhnRcoo1oe7wQ+SP=40u9mkps6vXua8TQQ4Tbf2qKOQ@mail.gmail.com> <50F927A5.5060409@redhat.com> <50F94FA6.6070005@systemhalted.org> <50F95B0A.1090205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Carlos O'Donell" <carlos@systemhalted.org>,
        Mike Frysinger <vapier@gentoo.org>, David Miller <davem@davemloft.net>,
        libc-alpha@sourceware.org, bhutchings@solarflare.com,
        amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <libc-alpha-return-36419-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <50F95B0A.1090205@linux-ipv6.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On 01/18/2013 02:24 PM, YOSHIFUJI Hideaki wrote:

>>>> It's simple enough to move all of the __GLIBC__ uses into libc-compat.h,
>>>> then you control userspace libc coordination from one file.
>>>
>>> How about just deciding on a single macro/symbol both the
>>> kernel and libc (any libc that needs this) define?  Something
>>> like both the kernel and userland doing:
>>>
>>> #ifndef __IPV6_BITS_DEFINED
>>> #define __IPV6_BITS_DEFINED
>>> ...
>>> define in6_addr, sockaddr_in6, ipv6_mreq, whatnot
>>> #endif
> 
> Hmm, how should we handle future structs/enums then?
> For example, if I want to have in6_flowlabel_req{} defined in
> glibc, what should we do?

Include the glibc header first?  Or is this some other
use case?

The point wasn't that you'd have only one macro for all
structs/enums (you could split into __IPV6_IN6_ADDR_DEFINED,
__IPV6_SOCKADDR_IN6_DEFINED, etc.) but to have the kernel
and libc agree on guard macros, instead of having the kernel
do #ifdef __GLIBC__ and glibc doing #ifdef _NETINET_IN_H.

But as Carlos says, the devil is in the details, and
I sure am not qualified on the details here.

-- 
Pedro Alves
