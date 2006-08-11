From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Fri, 11 Aug 2006 10:33:53 +0400
Message-ID: <20060811063353.GC11230@2ka.mipt.ru>
References: <11551105602734@2ka.mipt.ru> <20060809152127.481fb346.akpm@osdl.org> <20060810061433.GA4689@2ka.mipt.ru> <20060810001844.ff5e7429.akpm@osdl.org> <20060810075047.GB24370@2ka.mipt.ru> <20060810010254.3b52682f.akpm@osdl.org> <20060810082235.GA21025@2ka.mipt.ru> <20060810175639.b64faaa9.akpm@osdl.org> <20060811061535.GA11230@2ka.mipt.ru> <44DC22C1.1060200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:14574 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932067AbWHKGek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 02:34:40 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44DC22C1.1060200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2006 at 11:25:05PM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> > The main disadvantage is that all memory is allocated on the start =
even
> > if it will not be used later. I think dynamic grow is appropriate
> > solution, since user will have that memory used anyway, since keven=
ts
> > are allocated,
>=20
> If you _allocate_ memory at startup you're doing something wrong.  Al=
l
> you should do is allocate address space.  Memory should be allocated
> when it is needed.
>=20
> Growing a memory region is always hard because it means you cannot ke=
ep
> any addresses around and always have to reload a base pointer.  That'=
s
> not ideal.
>
> Especially on 64-bit machines address space really is no limitation
> anymore.  So, allocate as much as needed, allocate memory when it's
> needed, and don't resize.

That requires mmap hacks to substitute pages in run-time without user
notifications. I do not expect it is a good solution, since on x86 it
requires full TLB flush (at least when I did it there were no exported
methods to flush separate addresses).

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
>=20



--=20
	Evgeniy Polyakov
