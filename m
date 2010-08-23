From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 22:48:58 +0200
Message-ID: <1282596538.2378.340.camel@edumazet-laptop>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
	 <1282593694.2378.230.camel@edumazet-laptop>
	 <20100823202452.GC12906@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32782 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab0HWUtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:49:07 -0400
Received: by wwe15 with SMTP id 15so631487wwe.1
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 13:49:05 -0700 (PDT)
In-Reply-To: <20100823202452.GC12906@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 16:24 -0400, Neil Horman a =C3=A9crit=
 :

>=20
> Faster I agree with, although I'm not sure if speed is really a big i=
ssue here,
> given that this is a ancient (but fairly well used) 10/100 adapter.  =
And we
> still have space in the octet that that bitfield is living in, so I f=
igured I'd
> use that anyway.
>=20
> As for safe, I'm not sure I follow you on that point.  Is there somet=
hing
> inherently dangerous about using a bitfield in this case?
>=20

A bitfield is not SMP safe.

Are you sure another cpu is not changing another bit, using a non atomi=
c
RMW sequence, and your bit change is lost ?

Quite tricky to check I suppose, so just add an "int" ;)



