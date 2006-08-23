From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 17:11:31 +0400
Message-ID: <20060823131130.GA29056@2ka.mipt.ru>
References: <20060822.173200.126578369.davem@davemloft.net> <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com> <20060823065659.GC24787@2ka.mipt.ru> <b3f268590608230122k60e3c7c7y939d5559d97107f@mail.gmail.com> <20060823083859.GA8936@2ka.mipt.ru> <b3f268590608230249q653e1dfh1d77c07f6f4e82ce@mail.gmail.com> <20060823102037.GA23664@2ka.mipt.ru> <b3f268590608230334y6814b886tb79da2f59138acd8@mail.gmail.com> <20060823105104.GA11305@2ka.mipt.ru> <b3f268590608230555o3a03d9d6l1d99a32695e8af6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20889 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750770AbWHWNMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 09:12:46 -0400
To: Jari Sundell <sundell.software@gmail.com>
Content-Disposition: inline
In-Reply-To: <b3f268590608230555o3a03d9d6l1d99a32695e8af6a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 02:55:47PM +0200, Jari Sundell (sundell.software@gmail.com) wrote:
> On 8/23/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >We still do not know what uintptr_t is, and it looks like it is a pointer,
> >which is forbidden. Those numbers are not enough to make network AIO.
> >And actually is not compatible with kqueue already, so you will need to
> >write your own parser to convert your parameters into above structure.
> 
> 7.18.1.4 Integertypes capable of holding object pointers
> 
> "1 The following type designates a signed integer type with the
> property that any valid
> pointer to void can be converted to this type, then converted back to
> pointer to void,
> and the result will compare equal to the original pointer:"
> 
> Dunno if this means that x86-64 needs yet another typedef, or if using
> long for intptr_t is incorrect. But assuming a different integer type
> was used instead of intptr_t, that is known to be able to hold a
> pointer, would there still be any problems?

stdint.h

/* Types for `void *' pointers.  */
#if __WORDSIZE == 64
# ifndef __intptr_t_defined
typedef long int		intptr_t;
#  define __intptr_t_defined
# endif
typedef unsigned long int	uintptr_t;
#else
# ifndef __intptr_t_defined
typedef int			intptr_t;
#  define __intptr_t_defined
# endif
typedef unsigned int		uintptr_t;
#endif

which means that with 32bit userspace it will be equal to 32bit only.

> I'm unable to see anything specific about AIO in your kevent patch
> that these modifications wouldn't support.

I was asked to postpone AIO stuff for now, you can find it in previous
patchsets sent about week or two ago.

> Rakshasa

-- 
	Evgeniy Polyakov
