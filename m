From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v3 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 15:11:32 -0700
Message-ID: <CAEU2+vr823WcoF_Z4NV7ptWNBQ4uTG+tD2VAXbQPDYGqsaKpLQ@mail.gmail.com>
References: <1328551064-28573-2-git-send-email-ehoover@mines.edu>
	<4F30428B.2080102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:42169 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238Ab2BFWLr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 17:11:47 -0500
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q16MBkx7024569
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 6 Feb 2012 15:11:47 -0700
Received: by vbjk17 with SMTP id k17so4213888vbj.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 14:11:46 -0800 (PST)
In-Reply-To: <4F30428B.2080102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2012 at 2:13 PM, Brian Haley <brian.haley@hp.com> wrote:
> On 02/06/2012 12:57 PM, Erich E. Hoover wrote:
> > ...
> > + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 outif_index;
> ...
> Nitpick: is ucast_oif a better name?

I templated off of the IPv4 code (example: mc_index), but I do think
that that is a better name.  Should I call the IPv4 version
"ucast_index" or have the same name for both IPv4 and IPv6?

> > diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> > index 01d46bf..18f144e 100644
> > --- a/net/ipv6/icmp.c
> > +++ b/net/ipv6/icmp.c
> > @@ -551,6 +551,9 @@ static void icmpv6_echo_reply(struct sk_buff *s=
kb)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> > =A0 =A0 =A0 np =3D inet6_sk(sk);
> >
> > + =A0 =A0 if (!fl6.flowi6_oif)
> > + =A0 =A0 =A0 =A0 =A0 =A0 fl6.flowi6_oif =3D ipv6_default_ifindex(s=
k);
> > +
> > =A0 =A0 =A0 if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.dadd=
r))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl6.flowi6_oif =3D np->mcast_oif;
>
> This snippet shows (and rawv6_sendmsg() has the same problem), that
> IPV6_UNICAST_IF can also affect multicast packets. =A0And I think we =
always want
> SO_BINDTODEVICE to override them all. =A0Perhaps these checks should =
be:
> ...

I'll double check all of these tonight, but a cursory look seems to
indicate that the multicast check is the right place to put this for
all the files.  I'm sorry about that, I clearly didn't consider
interfering with multicast.

Erich Hoover
ehoover@mines.edu
