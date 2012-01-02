From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 02 Jan 2012 17:29:05 +0100
Message-ID: <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44328 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab2ABQ3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:29:08 -0500
Received: by wgbdr13 with SMTP id dr13so26775823wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 08:29:07 -0800 (PST)
In-Reply-To: <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 17:08 +0100, Jean-Michel Hautbois a =C3=
=A9crit :

> Yes, and again, I don't want any missing lines :).
>=20

Go for tcp :)


> I don't really know what it can do, but it has to do encoding (even i=
f
> it is a SoC, with dedicated devices, memory has to be used).
> The main problem I have, is that I don't have the two boards with me
> today, and even if I can prototype on x86, I can't conclude as far as
> I don't test on the real HW.

Thats going to be tough. You could at least use one board and test if i=
t
can send 100Mbits using netperf (on a x86 target), and check cpu usage.

> This is also why I want to prototype my best bet in the first try :).
> And this is mainly a networking/memory problem.

If the 'no packet loss happens in the network' requirement is OK, then =
a
plain sendfile() [ or splice() ] will work.

Limiting each tcp frame to a 1 or 2 lines of your image is about
limiting MSS on your tcp session (setsockopt( ... TCP_MAXSEG ))
