From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sun, 25 Apr 2010 16:03:03 +0800
Message-ID: <k2h412e6f7f1004250103g3fbce599r8337fdb781317158@mail.gmail.com>
References: <20100424.225128.52181685.davem@davemloft.net>
	<z2h412e6f7f1004242348ibd5f96a2i7cd0557c37bb0921@mail.gmail.com>
	<20100425.003834.147984813.davem@davemloft.net> <20100425.004842.225645379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:55777 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab0DYIDX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 04:03:23 -0400
Received: by iwn8 with SMTP id 8so4051595iwn.16
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 01:03:23 -0700 (PDT)
In-Reply-To: <20100425.004842.225645379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 3:48 PM, David Miller <davem@davemloft.net> wro=
te:
>
> Nevermind, currently we only depend upon the addresses in struct sock
> being 64-bit aligned not the protocol headers.
>
> It shouldn't be hard to make the protocol header addresses 64-bit
> aligned too. =C2=A0Simply setting the default NET_IP_ALIGN to '6' ins=
tead
> of '2' ought to be sufficient.
>
> skb->data upon alloc_skb() is 64-bit aligned.
>
> So if we skb_reserve(NET_IP_ALIGN '6'), then we have the ethernet
> header (14 bytes). =C2=A0And since 'saddr' is 12 bytes into struct ip=
hdr it
> will be (6 + 14 + 12) =3D=3D 32 bytes in from the original 64-bit ali=
gned
> skb->data.
>
> Therefore, since skb->data is 64-bit aligned, skb->data plus a
> multiple of 8 (which 32 is) will also be 64-bit aligned, and that
> means iph->saddr will be 64-bit aligned.
>

But if there is a vlan header, extra 4-bytes are appended to the
ethernet header, so the addresses aren't aligned to 64-bit boundary
when we set NET_IP_ALIGN to 6.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
