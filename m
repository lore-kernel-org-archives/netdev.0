From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 14:10:05 -0800
Message-ID: <AANLkTim+HaoTr_MdgFmWM3OeRttsAMsF1d++vm8gTo+N@mail.gmail.com>
References: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49276 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758319Ab0KSWKG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 17:10:06 -0500
Received: by gxk23 with SMTP id 23so3044428gxk.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 14:10:05 -0800 (PST)
In-Reply-To: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 12:04 PM, Tom Herbert <therbert@google.com> wro=
te:
> This is a project I'm contemplating.=A0 If you have any comments or c=
an
> point me to prior work in this area that would be appreciated.

> TX:
> =A0- Zero copy transmit (which is already supported by vmsplice(), bu=
t
> this might be simpler)
> =A0- One system call needed on transmit which can cover multiple
> datagrams or what would have been multiple writes (the call is just t=
o
> kick kernel to start sending)

I'd look at our existing recvmmsg syscall -- there was talk of doing a
sendmmsg, which sounds close to what you want.

> RX:
> =A0- Zero system calls needed to do receive (determining data ready i=
s
> accomplished by polling)
> =A0- Immediate data placement in kernel available all the time,
> including OOO placement
> =A0- Potential for true zero copy on receive with device support (lik=
e
> per flow queues, UDP queues)

Mentioning zero-copy per-flow queues in userspace suggests Infiniband
is prior work in this area.

Regards -- Andy
