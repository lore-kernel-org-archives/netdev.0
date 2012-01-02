From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 02 Jan 2012 17:52:17 +0100
Message-ID: <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43444 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab2ABQwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:52:20 -0500
Received: by werm1 with SMTP id m1so7490512wer.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 08:52:19 -0800 (PST)
In-Reply-To: <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois a =C3=
=A9crit :

> Mmmh, using netperf you would like to know what the client (my ARM
> board) can do ?
> How would you test it ? I can have an ARM board on one side, and the
> x86 on the other...
>=20

x86> netserver &
arm> netperf -H <arm_ip_address> -l 60 -t TCP_STREAM

1) check cpu usage on <arm> while test is running=20
(for example : vmstat 1 )
2) check bandwith of test run=20


> Yes, the idea of limiting tcp frame to 2 lines is to avoid
> fragmenting. So, with a MTU at 1500, MSS=3D1460, I can put 2 lines <=3D
> 730bytes. I will probably have ~700bytes.

There is no fragmentation on TCP.

You should just let TCP stack use the best MSS (MTU - 40 or so), to
lower cpu usage both on sender and receiver.

Eventually, check if you can use a big MTU on your dedicated ethernet
link to fit 4 lines per tcp frame.
