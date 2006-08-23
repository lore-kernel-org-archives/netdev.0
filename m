From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 14:51:04 +0400
Message-ID: <20060823105104.GA11305@2ka.mipt.ru>
References: <20060822231129.GA18296@ms2.inr.ac.ru> <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com> <20060822.173200.126578369.davem@davemloft.net> <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com> <20060823065659.GC24787@2ka.mipt.ru> <b3f268590608230122k60e3c7c7y939d5559d97107f@mail.gmail.com> <20060823083859.GA8936@2ka.mipt.ru> <b3f268590608230249q653e1dfh1d77c07f6f4e82ce@mail.gmail.com> <20060823102037.GA23664@2ka.mipt.ru> <b3f268590608230334y6814b886tb79da2f59138acd8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964852AbWHWKxT@vger.kernel.org>
To: Jari Sundell <sundell.software@gmail.com>
Content-Disposition: inline
In-Reply-To: <b3f268590608230334y6814b886tb79da2f59138acd8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 12:34:25PM +0200, Jari Sundell (sundell.software@gmail.com) wrote:
> On 8/23/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >
> >No, it will change sizes of the structure in kernelspace and userspace,
> >so they just can not communicate.
> 
> struct kevent {
>  uintptr_t ident;        /* identifier for this event */
>  short     filter;       /* filter for event */
>  u_short   flags;        /* action flags for kqueue */
>  u_int     fflags;       /* filter flag value */
> 
>  union {
>    u32       _data_padding[2];
>    intptr_t  data;         /* filter data value */
>  };

As Eric pointed it must be aligned.

>  union {
>    u32       _udata_padding[2];
>    void      *udata;       /* opaque user data identifier */
>  };
> };
> 
> I'm not missing anything obvious here, I hope.

We still do not know what uintptr_t is, and it looks like it is a pointer, 
which is forbidden. Those numbers are not enough to make network AIO.
And actually is not compatible with kqueue already, so you will need to
write your own parser to convert your parameters into above structure.

> Rakshasa
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
