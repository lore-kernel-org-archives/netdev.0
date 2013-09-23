From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problem with tap interface: link is not ready
Date: Mon, 23 Sep 2013 09:14:50 -0700
Message-ID: <20130923091450.7615cc60@samsung-9>
References: <1379951507.84403.YahooMailNeo@web172101.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dani Camps <danicamps81@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:41369 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab3IWQO6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 12:14:58 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so3366608pbc.7
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 09:14:58 -0700 (PDT)
In-Reply-To: <1379951507.84403.YahooMailNeo@web172101.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Sep 2013 16:51:47 +0100 (BST)
Dani Camps <danicamps81@yahoo.com> wrote:

>=20
>=20
> Dear all,
>=20
> I am not sure that I am addressing the correct mailing list. In case =
I am not, please accept my apologies.
>=20
> I am trying to create a virtual tap device that I want to add later o=
n to a bridge. My problem is that the tap interface always appears with=
 state disabled if I do a =C2=B4brctl showstp br0=C2=B4, and no traffic=
 reaches the bridge.=C2=A0After some investigation I found out that the=
 tap interface is never up. How can I bring the tap interface up?
>=20
> These are my detailed steps:
>=20
> sudo tunctl -t tap0
> sudo ifconfig tap0 192.168.0.2/24 up
>=20
> But when I look at dmesg I get:
>=20
> =C2=A0ADDRCONF(NETDEV_UP): tap0: link is not ready
>=20
>=20
> Nevertheless if I do 'ifconfig tap0' it seems to indicate that the in=
terface is up:
>=20
> tap0 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 72:a0:fb:88=
:95:44
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 inet addr:192.168.0.2 =C2=A0Bcast:=
192.168.0.255 =C2=A0Mask:255.255.255.0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UP BROADCAST MULTICAST =C2=A0MTU:1=
500 =C2=A0Metric:1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX packets:0 errors:0 dropped:0 ov=
erruns:0 frame:0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TX packets:0 errors:0 dropped:0 ov=
erruns:0 carrier:0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 collisions:0 txqueuelen:500
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX bytes:0 (0.0 B) =C2=A0TX bytes:=
0 (0.0 B)
>=20
> But I never see a message in dmesg saying "tap0: link becomes ready."=
 And when I add the tap0 interface it always appears disabled, so I thi=
nk that the interface is never really up.
>=20
> My kernel is 3.0
>=20
> Any help to bring up the tap interface is much appreciated.
>=20
> Best Regards
>=20
> Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The carrier state of the TAP device is up if a program has the tap devi=
ce handle open.
If no program has the tap device open then carrier (IFF_RUNNING) will b=
e down.
The bridge with STP monitors carrier state to decide whether to use the=
 network
device.

In summary, unless you have an application using tap, the device will l=
ook
to network as if cable is unplugged.
