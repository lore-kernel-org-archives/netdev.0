From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: nonlocal_bind and IPv6
Date: Thu, 15 Dec 2011 19:58:01 -0800
Message-ID: <CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43197 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab1LPD6C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 22:58:02 -0500
Received: by iaeh11 with SMTP id h11so3723945iae.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 19:58:01 -0800 (PST)
In-Reply-To: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

why not simply use the IP_TRANSPARENT or IP_FREEBIND socket options?

On Wed, Dec 14, 2011 at 08:20, Vincent Bernat <bernat@luffy.cx> wrote:
> This is a second tentative to port ip_nonlocal_bind to IPv6. The two
> patches are independant. The first patch enables
> net.ipv6.ip_nonlocal_bind and is "namespace aware". The second patch
> modifies net.ipv4.ip_nonlocal_bind to also be "namespace aware". I
> don't know if this is something important.
>
> I did not test the SCTP part of the second patch (but it compiles).
>
> =C2=A0Documentation/networking/ip-sysctl.txt | =C2=A0 =C2=A05 +++++
> =C2=A0include/net/netns/ipv4.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0include/net/netns/ipv6.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0net/ipv4/af_inet.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A06 +-----
> =C2=A0net/ipv4/ping.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0net/ipv4/sysctl_net_ipv4.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 16 +++++++++-------
> =C2=A0net/ipv6/af_inet6.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A06 ++++--
> =C2=A0net/ipv6/sysctl_net_ipv6.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 =C2=A08 ++++++++
> =C2=A0net/sctp/protocol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A09 files changed, 31 insertions(+), 16 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
