From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Fri, 27 Dec 2013 17:28:37 +0900
Message-ID: <1388132917.8290.22.camel@ubuntu-vm-makita>
References: <eb3c68d9-fa1b-402a-9416-1ea38a78b68b@mailpro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41052 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab3L0I2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 03:28:49 -0500
In-Reply-To: <eb3c68d9-fa1b-402a-9416-1ea38a78b68b@mailpro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013-12-26 (=E6=9C=A8) =E3=81=AE 14:57 +0100 =E3=81=AB Alexandre DERUMI=
ER =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=97=E3=81=
=9F:
> Hello Again,
>=20
> One more question :
>=20
> If I use tcpdump on br0, I don't see any tagged vlan10 packets on the=
 bridge.
> with=20
> # bridge vlan add dev tap0 vid 10 pvid untagged=20
> # bridge vlan add dev tap1 vid 10 pvid untagged=20

With these settings, you should be able to see tagged frames on bridge
device with promisc mode.
Are you sure you enabled vlan_filtering by sysfs?
Or didn't you set br0 in the same way as other ports like below?
# bridge vlan add dev br0 vid 10 pvid untagged self

>=20
>=20
> What I would like to do, is tagging vlan10, incoming (untagged) packe=
ts from tap0 and tap1.
>=20
> Is it possible ?

If you set pvid, incoming frames from the port will be tagged with the
vlan.
If you set untagged, outgoing frames with the vlan from the port will b=
e
untagged.

So, if you want to send frames tagged with vlan 10, please don't set vi=
d
10 untagged on outgoing ports you want.


BTW:
(CC: Vlad)
I tested to execute tcpdump on br0 with vlan_filtering enabled, but
kernel panic occurred with upstream net-tree kernel. br_handle_vlan()
seems to have a bug that it doesn't check pv is NULL or not.
br_pass_frame_up() calls br_handle_vlan() even if br->vlan_info is NULL
when bridge device is promisc mode.
This will occur if we don't add any vlan on the bridge device.
I'm going to make a patch to fix it.

Thanks,
Toshiaki Makita

>=20
> With openvswitch, I can do it simply with "ovs-vsctl set port tap0 ta=
g=3D10"
>=20
