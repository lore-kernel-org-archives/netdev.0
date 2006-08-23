From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 12:34:25 +0200
Message-ID: <b3f268590608230334y6814b886tb79da2f59138acd8@mail.gmail.com>
References: <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com>
	 <20060822231129.GA18296@ms2.inr.ac.ru>
	 <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com>
	 <20060822.173200.126578369.davem@davemloft.net>
	 <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
	 <20060823065659.GC24787@2ka.mipt.ru>
	 <b3f268590608230122k60e3c7c7y939d5559d97107f@mail.gmail.com>
	 <20060823083859.GA8936@2ka.mipt.ru>
	 <b3f268590608230249q653e1dfh1d77c07f6f4e82ce@mail.gmail.com>
	 <20060823102037.GA23664@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	nmiell@comcast.net, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.206]:15210 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S964824AbWHWKe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 06:34:27 -0400
Received: by nz-out-0102.google.com with SMTP id n1so47661nzf
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 03:34:26 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060823102037.GA23664@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
> No, it will change sizes of the structure in kernelspace and userspace,
> so they just can not communicate.

struct kevent {
  uintptr_t ident;        /* identifier for this event */
  short     filter;       /* filter for event */
  u_short   flags;        /* action flags for kqueue */
  u_int     fflags;       /* filter flag value */

  union {
    u32       _data_padding[2];
    intptr_t  data;         /* filter data value */
  };

  union {
    u32       _udata_padding[2];
    void      *udata;       /* opaque user data identifier */
  };
};

I'm not missing anything obvious here, I hope.

Rakshasa
