From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Fix VLAN tag stripping on Intel i350
Date: Wed, 27 Jan 2016 11:25:22 -0800
Message-ID: <1453922722.3014.29.camel@intel.com>
References: <1453901284-32628-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ts9jUHQWVpCKyu9usqAa"
Cc: netdev@vger.kernel.org
To: Corinna Vinschen <vinschen@redhat.com>,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58935 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966625AbcA0TZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 14:25:24 -0500
In-Reply-To: <1453901284-32628-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ts9jUHQWVpCKyu9usqAa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-27 at 14:28 +0100, Corinna Vinschen wrote:
> Problem: When switching off VLAN offloading on an i350, the VLAN
> interface gets unusable.=C2=A0 For testing, set up a VLAN on an i350
> and some remote machine, e.g.:
>=20
> =C2=A0 $ ip link add link eth0 name eth0.42 type vlan id 42
> =C2=A0 $ ip addr add 192.168.42.1/24 dev eth0.42
> =C2=A0 $ ip link set dev eth0.42 up
>=20
> Offloading is switched on by default:
>=20
> =C2=A0 $ ethtool -k eth0 | grep vlan-offload
> =C2=A0 rx-vlan-offload: on
> =C2=A0 tx-vlan-offload: on
>=20
> =C2=A0 $ ping -c 3 -I eth0.42 192.168.42.2
> =C2=A0 [...works as usual...]
>=20
> Now switch off VLAN offloading and try again:
>=20
> =C2=A0 $ ethtool -K eth0 rxvlan off
> =C2=A0 Actual changes:
> =C2=A0 rx-vlan-offload: off
> =C2=A0 tx-vlan-offload: off [requested on]
> =C2=A0 $ ping -c 3 -I eth0.42 192.168.42.2
> =C2=A0 PING 192.168.42.2 (192.168.42.2) from 192.168.42.1 eth0.42: 56(84)
> bytes of data.
>=20
> =C2=A0 --- 192.168.42.2 ping statistics ---
> =C2=A0 3 packets transmitted, 0 received, 100% packet loss, time 1999ms
>=20
> I can only reproduce it on an i350, the above works fine on a 82580.
>=20
> While inspecting the igb source, I came across the code in
> igb_set_vmolr
> which sets the E1000_VMOLR_STRVLAN/E1000_DVMOLR_STRVLAN flags once
> and
> for all, and in all of the igb code there's no other place where the
> STRVLAN is set or cleared.=C2=A0 Thus, VLAN stripping is enabled in igb
> unconditionally, independently of the offloading setting.
>=20
> I compared that to the latest Intel igb-5.3.3.5 driver from
> http://sourceforge.net/projects/e1000/=C2=A0which in fact sets and clears
> the
> STRVLAN flag independently from igb_set_vmolr in its own function
> igb_set_vf_vlan_strip, depending on the vlan settings.
>=20
> So I included the STRVLAN handling from the igb-5.3.3.5 driver into
> our
> current igb driver and tested the above scenario again.=C2=A0 This time
> ping
> still works after switching off VLAN offloading.
>=20
> Tested on i350, with and without addtional VFs, as well as on 82580
> successfully.
>=20
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
> ---
> =C2=A0drivers/net/ethernet/intel/igb/igb_main.c | 39
> ++++++++++++++++++++++++-------
> =C2=A01 file changed, 31 insertions(+), 8 deletions(-)

I tried applying your patch to my tree for review and validation, but
due to patches already applied against the igb driver in my tree, your
patch does not apply cleanly.

Can you please update your patch to apply cleanly to my tree?
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

(next-queue tree and dev-queue branch)
--=-Ts9jUHQWVpCKyu9usqAa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWqRmiAAoJEOVv75VaS+3OSP4P/REMz91LDBvSdjtfA0IKVdq0
i1JPCBvQs4zmHudyJKj08Uw4eD632D+xVUYD1tafLQQiwL0rXrWBCP04k9PP1uOY
EuJnOyHjuXJJqyBkPkzkcwlUcZaVXJOUIQWqG7BmWl/+w81VHlmT1EZwnCK8lSzP
ZWAzLFs5cdJjmga0l9umDeDB3erJ5meiret8jUfS/4p8vLyj3cfv2F9p4dmW2au7
W+QfGPlrFvI/XXFydtmyNKhYuZ9kSTHQm69sUPa3Yo+W8tpIIdAo+oqXITk86odV
N7kxHPwra4Q0niTT4dJiROIrfaQk5QJjpr9HJVqyWYOz8nC57Q1M9T1cojf8ktzU
M7a1XzbOBSZTL+1N8UjoRv7yRGVqeaJxtp19eWaywb1inrXfFmSMXAQ0LgRBRp4L
q+2AZgaDnhK90inxCvOcjegBu/tv4tW70lXta7KeV3uGpadFuEyGwAF/Pj0VMrvZ
26fQkQyx1SiyvE6xcbBYYLp9oytP9ZesfJetiDNn4jadAha3Y0ysq1Vibb6XKY33
rXH8bcmEJgT3Ri9+7knsq6neuJ+xhkZBs0e3eGA/ZtWuJeCzpxnVmLb9PdTwEh7P
5KaUv9qtAbvOmqYKr8nvOBr6Duio++g8fOpqC2bYuNyLZ08sta8qTwRSwid0vZVd
IoJPfItfRbZM8MKFhvQS
=brAN
-----END PGP SIGNATURE-----

--=-Ts9jUHQWVpCKyu9usqAa--
