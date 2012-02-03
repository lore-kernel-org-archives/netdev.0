From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 2 Feb 2012 18:22:51 -0700
Message-ID: <CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	<1328219828.2480.32.camel@edumazet-laptop>
	<CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	<1328222744.2480.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:57607 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932290Ab2BCBWw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 20:22:52 -0500
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(authenticated bits=0)
	by izzard.mines.edu (8.13.8/8.13.8) with ESMTP id q131Mp4V016157
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 2 Feb 2012 18:22:52 -0700
Received: by vcge1 with SMTP id e1so2260665vcg.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 17:22:51 -0800 (PST)
In-Reply-To: <1328222744.2480.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 3:45 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 02 f=E9vrier 2012 =E0 15:29 -0700, Erich E. Hoover a =E9crit=
 :
> > ...
> > Would it be better if ip_default_ifindex performed the same compari=
son
> > and prioritized the sk->sk_bound_dev_if value?
> I guess you should mimic other OS behavior. Tests are probably needed=
=2E

This isn't the best example since the test machines only have one NIC
and the loopback adapter (the loopback adapter acts differently), but
I generated some test results on the Wine TestBot.

Where bind() and IP_UNICAST_IF match:
https://testbot.winehq.org/JobDetails.pl?Key=3D16802

Mismatch between bind() and IP_UNICAST_IF:
https://testbot.winehq.org/JobDetails.pl?Key=3D16803

In both cases the loopback adapter rejects IP_UNICAST_IF and the test
"succeeds" for the NIC (the packet comes back on the same interface).
In both cases IP_UNICAST_IF is set before bind(), so this would seem
to indicate that bind() overrides IP_UNICAST_IF even if the bind()
occurs afterward.

> > > IPv6 not supported ?
> >
> > Nope, at least according to the documentation the option is only fo=
r
> > IPv4 (IPPROTO_IP).
>
> Probably because of the mix on interface index and IPv4 addr on "othe=
r
> OS".
>
> But if we implement interface index only, it could be used on IPv6
> too... I dont know...

I though I should double check this, and apparently I missed that
there's an equivalent IPV6_UNICAST_IF on "other OS".  Should that be a
patch 2 or should it be included in this one?

Erich Hoover
ehoover@mines.edu
