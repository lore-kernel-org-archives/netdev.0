From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH net 0/5] batman-adv: Fixes for Linux 4.7
Date: Sun, 26 Jun 2016 11:15:12 +0200
Message-ID: <10049349.EHEiaYmtBd@sven-edge>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8580419.SWsXJJWQec";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Antonio Quartulli <a@unstable.cc>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart8580419.SWsXJJWQec
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

Hi David,

Antonio currently seems to be occupied. This is currently rather unfort=
unate=20
because there are patches waiting in the batman-adv development reposit=
ory=20
maint(enance) branch [1] since up to 6 weeks. I am now getting asked wh=
en=20
these patches will hit the distribution kernels and therefore decided t=
o=20
submit these patches directly to netdev.

The patch from Simon works around the problem that warnings could be tr=
iggered=20
in the translation table code via packets using a VLAN not configured o=
n the=20
target host. This warning was replaced with a rate limited info message=
.

Ben Hutchings found an superfluous batadv_softif_vlan_put in the error=20=

handling code of the translation table while he backported the "batman-=
adv:=20
Fix reference counting of vlan object for tt_local_entry" patch to the =
stable=20
kernels. He noticed correctly that this batadv_softif_vlan_put should a=
lso=20
have been removed by the said patch.

The most requested fix at the moment is related to a double free in the=
=20
translation table code. It is a race condition which mostly happens on =
systems=20
with multiple cores and multiple network interface attached to batman-a=
dv. Two=20
Freifunk communities which were haunted by weird crashes (with backtrac=
es=20
reporting problems in other parts of the kernel) were kind enough to te=
st this=20
patch. They reported that there systems are now running stable after ap=
plying=20
this patch.

An invalid memory access was detected in the batadv_icmp_packet_rr hand=
ling=20
code when receiving a skbuff with fragments. The last patch is fixing a=
 memory=20
leak when the interface is removed via .dellink. The code to fix it was=
 copied=20
from=20the code handling the legacy sysfs interface to remove netdevices =
from=20a=20
batman-adv netdevice.

There are still 28 patches in the development tree for v4.8 but I will =
leave=20
them to Antonio because these are cleanups and features and therefore f=
or net-
next.

Ben Hutchings (1):
      batman-adv: Fix double-put of vlan object

Simon Wunderlich (1):
      batman-adv: replace WARN with rate limited output on non-existing=
 VLAN

Sven Eckelmann (3):
      batman-adv: Fix use-after-free/double-free of tt_req_node
      batman-adv: Fix ICMP RR ethernet access after skb_linearize
      batman-adv: Clean up untagged vlan when destroying via rtnl-link

net/batman-adv/routing.c           |  1 +
net/batman-adv/soft-interface.c    |  9 +++++++
net/batman-adv/translation-table.c | 50 +++++++++++++++++++++++++++++++=
=2D------
net/batman-adv/types.h             |  2 ++
4 files changed, 53 insertions(+), 9 deletions(-)

Kind regards,
=09Sven

[1] https://git.open-mesh.org/batman-adv.git/shortlog/refs/heads/maint

--nextPart8580419.SWsXJJWQec
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb50gAAoJEF2HCgfBJntG4nUP/3bm0gFIv+2uTcZxRSkuU1aH
k2aT6aoi1bU2UpEmxcOVfIY7nsLo8GVtgxicesWN46vCDlfyKMEOPQEfp6KFj2hS
BXp5a0TwbVClznrMtFVKLT5LA2jtyamLHJ5eLKjM9xDECBWiL8o8LgzTXcDj06NA
Xoy8/IslIw8rArrJnig5rImQVmnqWsbGB9RwmV3/5wpMmQo2+A7kCPt5DbqFXa+d
Ty0L8uACRZxKMOmak0gPpXR4Jk5MUXVHV9Njku7fKtRvkP7mWj2ln/HIp82Emgs4
XrmC4oOVWYfWFkPAWW4p/H70Ht3PsIfCP4EjrOT04E/M4AmLwbVCvXs7rcyOPfMl
/YWe7TauYb9pWVtMr/NZGRKUG/MVDYYtt6scc6sy0VDqjtU29V0a40lHKkyIJVXF
+sleIQT4yWAfJ7ekFpsG4nNxNGShTIFxlojWY0yHIRj1z1iQ4yzqWqs4g3Fxs21L
4udQ/vf/GNeG87leivK6Z/Y5VkKzftAa3FRdz5EohBTEe3blvCNQh9BS+YF1e9Z6
/hAALGHk8HjBrlq0gSxai3pMDJ/4w4iYUD2oOB1j6I3t2lE9y1p5qkCIVfeP1UiN
5ULa7gKLi7bX7HDyMQPw0SAsSejXz2A3cN2z6CK05g8/JSCp2XmeYvvmxXV7mUtU
FBDoa9Z4Hj40eilvXL8U
=H0L4
-----END PGP SIGNATURE-----

--nextPart8580419.SWsXJJWQec--
