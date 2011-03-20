From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 10:36:24 +0100
Message-ID: <1300613784.2831.142.camel@edumazet-laptop>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
	 <1300609817.2831.56.camel@edumazet-laptop>
	 <201103201104.42183.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47308 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab1CTJg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 05:36:28 -0400
Received: by fxm17 with SMTP id 17so4762659fxm.19
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 02:36:27 -0700 (PDT)
In-Reply-To: <201103201104.42183.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 mars 2011 =C3=A0 11:04 +0200, R=C3=A9mi Denis-Courmont a=
 =C3=A9crit :
> Le dimanche 20 mars 2011 10:30:17 Eric Dumazet, vous avez =C3=A9crit =
:
> >=20
> > But application also needs to use : listen(fd, 8192)
>=20
> Application should pass INT_MAX anyway, unless it has a specific limi=
t, e.g.=20
> it can only handle one connection at time.
>=20

You'll be surprised how few of them do that actually

ss -a | head
State      Recv-Q Send-Q      Local Address:Port          Peer Address:=
Port  =20
LISTEN     0      8                       *:imaps                    *:=
*      =20
LISTEN     0      8                       *:pop3s                    *:=
*      =20
LISTEN     0      50                      *:mysql                    *:=
*      =20
LISTEN     0      8                       *:pop3                     *:=
*      =20
LISTEN     0      8                       *:imap2                    *:=
*      =20
LISTEN     0      511                     *:www                      *:=
*      =20


Yes, Apache itself uses 511 as its default listenbacklog

You'll need to change=20

ListenBacklog 8192



