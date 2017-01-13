From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Commit 1fe8e0... (include more headers in if_tunnel.h) breaks
 my user-space build.
Date: Fri, 13 Jan 2017 14:08:06 -0800
Message-ID: <20170113140806.01f65b8a@xeon-e3>
References: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
        <20170113114158.6e5c3461@xeon-e3>
        <6c983e7e-dbb3-3542-ffed-95f4d2f3c5bc@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, mikko.rapeli@iki.fi
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32935 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdAMWIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:08:19 -0500
Received: by mail-pf0-f178.google.com with SMTP id y143so37175798pfb.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 14:08:19 -0800 (PST)
In-Reply-To: <6c983e7e-dbb3-3542-ffed-95f4d2f3c5bc@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jan 2017 11:50:32 -0800
Ben Greear <greearb@candelatech.com> wrote:

> On 01/13/2017 11:41 AM, Stephen Hemminger wrote:
> > On Fri, 13 Jan 2017 11:12:32 -0800
> > Ben Greear <greearb@candelatech.com> wrote:
> > =20
> >> I am including netinet/ip.h, and also linux/if_tunnel.h, and the linux=
/ip.h conflicts with
> >> netinet/ip.h.
> >>
> >> Maybe my build environment is screwed up, but maybe also it would be b=
etter to
> >> just let the user include appropriate headers before including if_tunn=
el.h
> >> and revert this patch?
> >>
> >>
> >> include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and lin=
ux/in6.h
> >>
> >>      Fixes userspace compilation errors like:
> >>
> >>      error: field =E2=80=98iph=E2=80=99 has incomplete type
> >>      error: field =E2=80=98prefix=E2=80=99 has incomplete type
> >>
> >>      Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> >>      Signed-off-by: David S. Miller <davem@davemloft.net>
> >>
> >> Thanks,
> >> Ben
> >> =20
> >
> > What I ended up doing for iproute2 was including all headers used by th=
e source
> > based on sanitized kernel headers.  Basically
> >   $ git grep '^#include <linux/' | \
> > 	awk -F: '{print $2}' | \
> > 	sed -e 's/^#include <//' -e 's/>.*$//' | \
> > 	sort -u >linux.headers
> >    $ for f in $(cat linux.headers)
> >      do cp ~/kernel/net-next/usr/include/$f include/$f
> >      done
> >
> > You can't take only some of the headers, once you decide to diverge fro=
m glibc provided
> > headers, you got to take them all.
> > =20
>=20
> I do grab a copy of the linux kernel headers and compile against that, bu=
t netinet/ip.h is
> coming from the OS.  Do you mean I should not include netinet/ip.h and in=
stead use linux/ip.h?

I don't think you can mix netinet/ip.h and linux/ip.h, yes that is a mess.
