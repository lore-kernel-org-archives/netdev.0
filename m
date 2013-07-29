From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch net-next v6 0/4] export device physical port id to
 userspace
Date: Mon, 29 Jul 2013 15:23:15 -0700
Message-ID: <1375136595.2104.13.camel@jtkirshe-mobl>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eAP/VfyqYvTdm2geA+O/"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com,
	or.gerlitz@gmail.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8647 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397Ab3G2WXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 18:23:16 -0400
In-Reply-To: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eAP/VfyqYvTdm2geA+O/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-07-29 at 18:16 +0200, Jiri Pirko wrote:
> This patchset is based on patch by Narendra_K@Dell.com
> Once device which can change phys port id during its lifetime adopts
> this,
> NETDEV_CHANGEPHYSPORTID event will be added and driver will call
> call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to
> propagate
> the change to userspace.
>=20
> v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped
> up ndo call)
> v2->v3: adjusted patch 1 commit message
> v3->v4: used "%phN" for sysfs printf as suggested by DaveM
>         added igb/igbvf implementation as requested by Or Gerlitz
> v4->v5: used prandom_u32 to generate id in igb_probe
>         removed duplicate code in ibgvf_probe
>         pushed dev_err string into one line in igbvf_refresh_ppid
> v5->v6: use uuid_le_gen for generating 16-byte phys port id for
> igb/igbvf
>         as suggested by BenH
>=20
> 1) Why do we need this, and why do existing facilities fail to provide
>    a way to accomplish this?
>=20
> Currenty there's very hard to tell if two netdevs are using the same
> physical
> port. For sr-iov this can be get by sysfs. For other mechanisms, like
> NPAR
> there's very hard to do it (one must learn it from NIC BIOS). But even
> for
> sr-iov there's no way to say if two netdevs are using the same phys
> port when
> these are passed through to virtual guests.
>=20
> This patchset provides the generic way of letting this information
> know to
> userspace. This info can be used by apps like NetworkManager, teamd,
> Wicked,
> ovs daemon, etc, to do smarter bonding decisions.
>=20
> 2) Why is the physical port ID defined as a 32 byte opaque cookie?
>    What formats and layouts need to be accomodated, and which
>    influenced the design of the ID?
>=20
> For user to distinguish if two netdevs are using the same port, he
> only needs
> to compare their phys port ids. Nothing else is needed. This id has no
> structure for security reasons. VF should not know anything about PF.
>=20
> 3) Are IDs globally unique?  Why or why not?  If IDs should be
>    globally unique, but only in certain cases, what exactly are those
>    cases.
>=20
> Most of the time only uniqueness needed is in scope of single machine.
> There might be case when the id should be unique between couple of
> machines
> in virtualization environment. Given that for example for igb/igbvf
> 16B uuid
> is used, there is no problem for this case as well. But each driver
> can
> implement this differently focusing the hw capabilities and needs.
>=20
> Jiri Pirko (4):
>   net: add ndo to get id of physical port of the device
>   rtnl: export physical port id via RT netlink
>   net: export physical port id via sysfs
>   igb/igbvf: implement ndo_get_phys_port_id=20

As before, I have applied this patch series so that we can get some
validation done on patch 4.  I do not want to hold up the patch series,
if Ben/Dave are fine with the recent changes, although I would like to
either get an ACK from Greg Rose or a thumbs up from our testers.

Thanks Jiri!

--=-eAP/VfyqYvTdm2geA+O/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR9utTAAoJEOVv75VaS+3OkGgP/AhtH8eBZygAc+z2sFSxJr65
kFyRz5xrPHj4YjbGhc0V70dJ3j/KenB4GEJJx7EqP6GqUCpLpRUP5Ey8ZeUgtFQn
xvQzQA0xaX+laJa+tRQjCiQ5yeMX3sZMszbrcawScLFLlBm5OPhZ8Gi0K6pl+0e1
LfFz1pQ3Nk7C0pJQTSNmhtbTScUdr6jYC8z7X3ClF6GbjDmtDZ0cvnLMOJizK6Bt
e3BIOd1W4qBaARJbL54tonsHwqfXmFwHmVGCWXznwGcBTEgcIHt1cHn4UGBiZiHW
CYeI9gkft1xhm5p3Svx44kHMU202GXnfl4oDqI7piixDuDGtj0h6IGnM9rdXTio7
Ibcws7Og1nGzJWJQ5TkYlVtYjlywPi8c97b73Kwc/5bcIqY83iBAqWi2nKDcLdpb
49Pd725hiY91zpoCtwrpaJYfnappB3skOZvmsj0lOCOQQIYcDEEmMho5jfL1zqTu
xGIWju7IlP0JeuG5dPyt6Yq8Tr/UF5x1nYp9+P6zKD5Kh7Qr8ah07RNY5YVjI6tA
1UqA0RGcqjN5/+iUHEmyQlNLjmvfY0pAQcX9ht2a//E6VJqPoDYpq3Tg2pk/6+5b
OFDF/f/W84VRQB/K71ZdFCeH8LfpMIzylk9eS+laQijz8JntLQcR+MMUe5niUhMq
FSCqqAXAmcHBoqk70/BP
=dqbt
-----END PGP SIGNATURE-----

--=-eAP/VfyqYvTdm2geA+O/--
