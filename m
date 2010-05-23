From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Receiving of priority tagged packets
Date: Sun, 23 May 2010 12:06:34 +0200
Message-ID: <1274609194.5020.68.camel@edumazet-laptop>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BEC@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:57995 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab0EWKGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 06:06:39 -0400
Received: by wwb13 with SMTP id 13so371052wwb.19
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 03:06:37 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BEC@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 mai 2010 =C3=A0 02:36 -0700, Vladislav Zolotarov a =C3=A9=
crit :
> Hello,
> We were playing with FCoE in our labs and saw the strange behavior of=
 Linux networking stack in regard to priority-tagged frames (the ones t=
hat have a zero VID in a VLAN tag). We saw that until we explicitly add=
ed a zero vlan interface (vconfig add ethX 0) the stack refused to acce=
pt such packets both in HW VLAN acceleration mode (skb is indicated usi=
ng vlan_hwaccel_receive_skb()) and in a regular mode (skb is indicated =
with netif_receive_skb()).
>=20
> However "IEEE Std 802.1Q, 2006 Edition DRAFT D0.1" in section 6.7 sta=
tes the following:=20
>=20
> Each Bridge Port shall support the following parameters for use by th=
ese (EISS tagging and detagging) functions:
> 	c) an Acceptable Frame Types parameter with at least one of the foll=
owing values:
> 		1) Admit Only VLAN-tagged frames;
> 		2) Admit Only Untagged and Priority-tagged frames;
> 		3) Admit All frames
>=20
> So I guess this means that priority tagged frames should be accepted =
together with the untagged frames on the default interface ethX.
>=20
> Could anyone explain, pls., what's the expected behavior of the Linux=
 Networking Stack in regard to the priority-tagged frames and what's ex=
pected to be configured in order to start accepting them?
>=20
> Thanks in advance,
> vlad

So if eth0.0 is setup, incoming vlanid=3D0 frames are delivered to eth0=
=2E0,
OK ? (This works in and out since commit 05423b241311c93)

Now, if eth0.0 is not setup, you believe these frames should be directe=
d
to eth0, as if they were not tagged ?

That seems a bit strange.



