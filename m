From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 09 Dec 2010 11:50:16 +0100
Message-ID: <1291891816.4063.5.camel@edumazet-laptop>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33504 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab0LIKuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 05:50:21 -0500
Received: by wwa36 with SMTP id 36so2296377wwa.1
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 02:50:20 -0800 (PST)
In-Reply-To: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 d=C3=A9cembre 2010 =C3=A0 16:03 +0530, Govindarajan, Sriram=
akrishnan a
=C3=A9crit :
> Hi
> We have a NAPI compliant driver(net/drivers/davinci_emac.c), that doe=
s well at 10/100Mbps loads. Now the same controller/driver is used for =
1000Mbps
> mode as well, where the CPU gets saturated easily
>=20
> Internally the module supports scatter gather DMA(which is currently =
not
> exercised) but there is no HW checksum support.
>=20
> To specifically implement GRO, GSO support would it be sufficient to =
add
> SG support to the driver? Are there other means of increasing the thr=
oughput
> and decreasing the CPU loading?
>=20
> Any pointers to reference implementation for adding SG/GRO/GSO suppor=
t will be helpful.

Adding GRO is pretty easy, since you already are NAPI.

call=20
	napi_gro_receive(&adapter->napi, skb)=20
instead of=20
	netif_receive_skb(skb);

(

Take commit 6a08d194ee4080 as an example of such conversion

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3D6a08d194ee40806e0ccd5f36ed768e64cbfc979f



