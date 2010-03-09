From: figo zhang <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Tue, 9 Mar 2010 09:50:29 +0800
Message-ID: <c6ed1ac51003081750v19f9d5fuf07ad0cc2478005d@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267798077.2576.17.camel@myhost>
	 <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
	 <c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
	 <f69abfc31003080610m2701309ekd1a4a38ac2685703@mail.gmail.com>
	 <f69abfc31003080611xde6fe26v150dd1fa90b82928@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:63211 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324Ab0CIB6g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 20:58:36 -0500
Received: by iwn6 with SMTP id 6so3128374iwn.4
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 17:58:35 -0800 (PST)
In-Reply-To: <f69abfc31003080611xde6fe26v150dd1fa90b82928@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/8 Yegor Yefremov <yegorslists@googlemail.com>:
> This is ping afterwards:
>
> debian:~# ping -c 1 192.168.1.38
>
> PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.
>
>
> =A0tx =A0 ram addr =3D c371c202 , data len =3D 62
>
> =A0dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800

=3D> the print info is not clear, it had better just keep "print_mem()"=
,
and remove other printk.

>
> =A00xc371c20e : 45 00
>
> =A00xc371c212 : 00 54 00 00 40 00 40 01 b6 f0 c0 a8 01 42 c0 a8
>
> =A00xc371c222 : 01 26 08 00 65 51 1a 07 00 01 92 00 95 4b 5f 57
>
> =A00xc371c232 : 07 00 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15
>
> =A00xc371c242 : 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25
>
> =A00xc371c252 : 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35
>
> =A00xc371c262 : 36 37
>
>
>
> =A0tx =A0 ram addr =3D c371c202 , data len =3D 2a
>
> =A0dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0806
>
> =A00xc371c20e : 00 01
>
> =A00xc371c212 : 08 00 06 04 00 01 00 04 d9 80 94 cd c0 a8 01 42
=3D> it is a send arp packet, "c0 a8 01 42" is your curr ip addr
192.168.1.66, tell the other side it's ip addr.
>
> =A00xc371c222 : 00 00 00 00 00 00 c0 a8 01 26
>
>
>
> =A0rx =A0 ram addr =3D c35d2020 , data len =3D 3c
>
> =A0dst:00:04:d9:80:94:cd src:00:18:f3:fe:84:84 type: 0x0806
>
> =A00xc35d202c : 00 01
>
> =A00xc35d2030 : 08 00 06 04 00 02 00 18 f3 fe 84 84 c0 a8 01 26

=3D> it is a reply arp packet, "c0 a8 01 26" (192.168.1.38 ) is other
side ip addr. so the arp
request is finished.

>
> =A00xc35d2040 : 00 04 d9 80 94 cd c0 a8 01 42 00 00 00 00 00 00
>
> =A00xc35d2050 : 00 00 00 00 00 00 00 00 00 00 00 00
>
=3D> so , it should still send  "IMCP" packet, you using "ping -c 1", i=
t
send one IMCP packet , and wait for reply.  at this point, it have not
send packet?
