From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Comment on nf_queue NF_STOLEN patch
Date: Tue, 18 Oct 2011 23:23:52 +0200
Message-ID: <1318973032.19139.5.camel@edumazet-laptop>
References: <4E988B1E.5000606@itcare.pl>
	 <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
	 <4E9DCEAD.7070603@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jim Sansing <jjsansing@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60411 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab1JRVX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 17:23:58 -0400
Received: by wwn22 with SMTP id 22so5524844wwn.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 14:23:56 -0700 (PDT)
In-Reply-To: <4E9DCEAD.7070603@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 15:08 -0400, Jim Sansing a =C3=A9crit :
> I have been working on a kernel module that registers with netfilter,
> and I noticed that a patch was added to nf_queue that changed the
> handling of return code NF_FILTER from 'do nothing' to 'free the skb'=
=2E=20
> I'm not sure which kernel version this went in, but the date of the
> patch is Feb, 19, 2010.
>=20
> Everything I have read about netfilter states that it is up to the
> netfilter hook to free the skb if NF_STOLEN is returned.  The
> implications of this patch from a hook programming perspective are:
>=20
> 1) If the skb is used after the return from the hook, it must be clon=
ed.
> 2) The original skb must not be freed.
>=20
> I suggest that a comment be added to include/linux/netfilter.h that s=
ays
> explicitly the skb will be freed if NF_STOLEN is returned.

But its not true. Just read the code.

If you are working on this stuff I recommend you take a look at
commits :

c6675233f9015d3c0460c8aab53ed9b99d915c64
(netfilter: nf_queue: reject NF_STOLEN verdicts from userspace)

fad54440438a7c231a6ae347738423cbabc936d9
(netfilter: avoid double free in nf_reinject)

64507fdbc29c3a622180378210ecea8659b14e40
(netfilter: nf_queue: fix NF_STOLEN skb leak)

3bc38712e3a6e0596ccb6f8299043a826f983701
([NETFILTER]: nf_queue: handle NF_STOP and unknown verdicts in
nf_reinject)
