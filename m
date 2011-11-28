From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET][TG3] Fwd: page allocation failure with linux 3.1.1
Date: Mon, 28 Nov 2011 20:28:14 +0100
Message-ID: <1322508494.2970.14.camel@edumazet-laptop>
References: <CALkh-HhkzHb7-2LAwCNOZ-S4otfeM+tthyw2_XDbDUjFRSkKjA@mail.gmail.com>
	 <CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com>
	 <1322462145.2826.6.camel@edumazet-laptop>
	 <CALkh-Hi=Pb_cNUzHrJSe4o5-kmb+jLA8vpw8hiaGxROzNJ6oag@mail.gmail.com>
	 <1322468762.2826.17.camel@edumazet-laptop> <4ED3DB91.9090409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?=D0=9F=D0=BB=D0=B0=D0=BC=D0=B5=D0=BD_?=
	 =?UTF-8?Q?=D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2?=
	<plamen.sisi@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42078 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753436Ab1K1T2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 14:28:21 -0500
Received: by lahl5 with SMTP id l5so661853lah.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 11:28:19 -0800 (PST)
In-Reply-To: <4ED3DB91.9090409@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 11:05 -0800, Rick Jones a =C3=A9crit :
> On 11/28/2011 12:26 AM, Eric Dumazet wrote:

> > Since some devices might copy skb to a linear one in their
> > ndo_start_xmit(), we could set a netdev limit so that TSO can still=
 be
> > used on these devices, but limiting number of frags to
> > 2^PAGE_ALLOC_COSTLY_ORDER
>=20
> How much "TSO value" remains after such a copy?

Instead of filling up to 64Kbytes + one head of data per skb, we'll fil=
l
32kbytes (8*4Kbytes) + one head.

Thats still better than 1460 bytes per skb :)
