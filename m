From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: Re: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Tue, 24 Dec 2013 20:28:55 +0100 (CET)
Message-ID: <338a04d5-a1bc-4446-b03b-e59fddcb65e8@mailpro>
References: <1387889105.3575.3.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:56071 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab3LXT3E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 14:29:04 -0500
In-Reply-To: <1387889105.3575.3.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>If you want to send untagged frames, please try to make configuration=
=20
>>like this:=20
>># bridge vlan add dev tap0 vid 10 pvid untagged=20
>># bridge vlan add dev tap1 vid 10 pvid untagged=20
>>
>>Thanks,=20
>>Toshiaki Makita=20

Thank you ! It's working now.
I thinked that "untagged" was for not tagging from the bridge, I unders=
tand now.

Thanks again and merry Xmas !


----- Mail original -----=20

De: "Toshiaki Makita" <makita.toshiaki@lab.ntt.co.jp>=20
=C3=80: "Alexandre DERUMIER" <aderumier@odiso.com>=20
Cc: netdev@vger.kernel.org=20
Envoy=C3=A9: Mardi 24 D=C3=A9cembre 2013 13:45:05=20
Objet: Re: bridge vlan_filtering don't work with tap devices (qemu gues=
ts)=20

On Mon, 2013-12-23 at 17:02 +0100, Alexandre DERUMIER wrote:=20
> Hello,=20
>=20
> I'm trying to use vlan_filtering on bridge.=20
>=20
> setup is : 2 qemu virtual machines (tap0 and tap1), plugged in a brid=
ge br0.=20
> virtual machines don't tag packets.=20
>=20
>=20
> qemuvm1 eth0 --tap0----->br0<-------tap1---qemuvm2 eth0.=20
>=20
>=20
> with vlan_filtering disable, both vms can ping together.=20
>=20
>=20
> If I enabled filtering=20
>=20
> #echo 1 > /sys/class/net/br0/bridge/vlan_filtering=20
>=20
> Both vms cannot ping together anymore.=20
>=20
> So, I have tried to put vlan on tap interfaces with=20
>=20
> #bridge vlan add dev tap0 vid 10=20
> #bridge vlan add dev tap1 vid 10=20

If you want to send untagged frames, please try to make configuration=20
like this:=20
# bridge vlan add dev tap0 vid 10 pvid untagged=20
# bridge vlan add dev tap1 vid 10 pvid untagged=20

Thanks,=20
Toshiaki Makita=20

> #bridge vlan show=20
> port vlan ids=20
> br0 None=20
> tap0 10=20
> tap1 10=20
>=20
>=20
>=20
> But, it doesn't work.=20
>=20
> tcpdump on bridge (tcpdump -i br0 -e -n) or in destination qemu (tcpd=
ump -i eth0 -e -n) , don't see any packet=20
>=20
> any idea ?=20
>=20
> Regards,=20
>=20
> Alexandre Derumier=20
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in=20
> the body of a message to majordomo@vger.kernel.org=20
> More majordomo info at http://vger.kernel.org/majordomo-info.html=20
