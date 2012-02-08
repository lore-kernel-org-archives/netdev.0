From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 1/2] Implement IP_UNICAST_IF socket option.
Date: Wed, 08 Feb 2012 08:21:57 +0100
Message-ID: <1328685717.4736.4.camel@edumazet-laptop>
References: <1328651073-976-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40903 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab2BHHWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 02:22:01 -0500
Received: by wgbdt10 with SMTP id dt10so282388wgb.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 23:22:00 -0800 (PST)
In-Reply-To: <1328651073-976-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 f=C3=A9vrier 2012 =C3=A0 14:44 -0700, Erich E. Hoover a =C3=
=A9crit :
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch =
implements the feature by setting the outgoing interface in a similar f=
ashion to that of IP_MULTICAST_IF.  A separate option is needed to hand=
le this feature since the existing options do not provide all of the ch=
aracteristics required by IP_UNICAST_IF, a summary is provided below.
>=20
> SO_BINDTODEVICE:
> * SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF d=
oes not.  From reading some old mailing list articles my understanding =
is that SO_BINDTODEVICE requires administrative privileges because it c=
an override the administrator's routing settings.
> * The SO_BINDTODEVICE option restricts both outbound and inbound traf=
fic, IP_UNICAST_IF only impacts outbound traffic.
>=20
> IP_PKTINFO:
> * Since IP_PKTINFO and IP_UNICAST_IF are independent options, impleme=
nting IP_UNICAST_IF with IP_PKTINFO will likely break some applications=
=2E
> * Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly compl=
icates the Wine codebase and reduces the socket performance (doing this=
 requires a lot of extra communication between the "server" and "user" =
layers).
>=20
> bind():
> * bind() does not work on broadcast packets, IP_UNICAST_IF is specifi=
cally intended to work with broadcast packets.
> * Like SO_BINDTODEVICE, bind() restricts both outbound and inbound tr=
affic.
>=20
> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>

This seems good, only the changelog is not formatted to fit in short
lines (70 cols)

Also title should include subsystem name  :

ipv4: Implement IP_UNICAST_IF socket option.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
