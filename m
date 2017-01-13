From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Commit 1fe8e0... (include more headers in if_tunnel.h) breaks
 my user-space build.
Date: Fri, 13 Jan 2017 11:41:58 -0800
Message-ID: <20170113114158.6e5c3461@xeon-e3>
References: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, mikko.rapeli@iki.fi
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34277 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdAMTmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:42:08 -0500
Received: by mail-pf0-f178.google.com with SMTP id 127so35208149pfg.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 11:42:07 -0800 (PST)
In-Reply-To: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jan 2017 11:12:32 -0800
Ben Greear <greearb@candelatech.com> wrote:

> I am including netinet/ip.h, and also linux/if_tunnel.h, and the linux/ip=
.h conflicts with
> netinet/ip.h.
>=20
> Maybe my build environment is screwed up, but maybe also it would be bett=
er to
> just let the user include appropriate headers before including if_tunnel.h
> and revert this patch?
>=20
>=20
> include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/=
in6.h
>=20
>      Fixes userspace compilation errors like:
>=20
>      error: field =E2=80=98iph=E2=80=99 has incomplete type
>      error: field =E2=80=98prefix=E2=80=99 has incomplete type
>=20
>      Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Thanks,
> Ben
>=20

What I ended up doing for iproute2 was including all headers used by the so=
urce
based on sanitized kernel headers.  Basically
  $ git grep '^#include <linux/' | \
	awk -F: '{print $2}' | \
	sed -e 's/^#include <//' -e 's/>.*$//' | \
	sort -u >linux.headers
   $ for f in $(cat linux.headers)
     do cp ~/kernel/net-next/usr/include/$f include/$f
     done

You can't take only some of the headers, once you decide to diverge from gl=
ibc provided
headers, you got to take them all.
