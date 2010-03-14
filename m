From: michael-dev@fami-braun.de
Subject: [PATCH] BUG: unable to handle kernel NULL pointer dereference at
 br_multicast_leave_group
Date: Sun, 14 Mar 2010 03:28:55 +0100
Message-ID: <4B9C49E7.1080703@fami-braun.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig30C71BC04313DF95D331E089"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:50530 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab0CNC3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 21:29:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig30C71BC04313DF95D331E089
Content-Type: multipart/mixed;
 boundary="------------010108080208000901000501"

This is a multi-part message in MIME format.
--------------010108080208000901000501
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I'm currently using linux-next and have been running into an OOPs which
I think might be caused by a patch you submitted on 2010-02-27.

It's a linux-next kernel from 2010-03-12 on an x86 system and it
OOPs in the bridge module in br_mdp_ip_get (called by
br_multicast_leave_group) because the br->mdb is null.

Digging deeper it seems that when a igmp leave packet is received, it is
not checked wether mdb has been populated yet. Though, if the group does
not exist, the code just skips leaving. So it seems the same action cna
be taken if mdb is still NULL. As far as I can see, commit
eb1d16414339a6e113d89e2cca2556005d7ce919 added multicast code to bridge
and so likely causes this crash. This crash does not happen on 2.6.33.

I've therefore modified br_multicast so that the leave is skipped if mdb
is empty.

Please don't hesitate to contact me if there are any questions.

Sincerely,
 M. Braun

// gdb output //
(gdb) print *((struct net_bridge*) 0xcec68800)
$3 =3D {lock =3D {{rlock =3D {raw_lock =3D {<No data fields>}}}}, port_li=
st =3D
{next =3D 0xcec41790, prev =3D 0xcfb209f8}, dev =3D 0xcec68520, hash_lock=
 =3D
{{rlock =3D {raw_lock =3D {<No data fields>}}}}, hash =3D {{first =3D 0x0=
},
{first =3D 0x0}, {first =3D 0x0}, {first =3D 0x0}, {
      first =3D 0xcfb4d980}, {first =3D 0x0} <repeats 19 times>, {first =3D=

0xcec41200}, {first =3D 0x0} <repeats 119 times>, {first =3D 0xcf00ea80},=

{first =3D 0x0} <repeats 29 times>, {first =3D 0xcfb6d680}, {first =3D 0x=
0}
<repeats 52 times>, {first =3D 0xcec40b00}, {first =3D 0x0}, {
      first =3D 0x0}, {first =3D 0x0}, {first =3D 0x0}, {first =3D 0x0}, =
{first
=3D 0x0}, {first =3D 0x0}, {first =3D 0xcf00d1c0}, {first =3D 0x0} <repea=
ts 20
times>}, feature_mask =3D 16726117, fake_rtable =3D {u =3D {dst =3D {rcu_=
head =3D
{next =3D 0x0, func =3D 0}, child =3D 0x0, dev =3D 0xcec68520,
        error =3D 0, obsolete =3D 0, flags =3D 2, expires =3D 0, header_l=
en =3D 0,
trailer_len =3D 0, rate_tokens =3D 0, rate_last =3D 0, path =3D 0xcec68c1=
0,
neighbour =3D 0x0, hh =3D 0x0, xfrm =3D 0x0, input =3D 0, output =3D 0, o=
ps =3D
0xd0cc2a40, metrics =3D {0, 1500, 0 <repeats 12 times>},
        tclassid =3D 0, __refcnt =3D {counter =3D 2}, __use =3D 0, lastus=
e =3D 0,
{next =3D 0x0, rt_next =3D 0x0, rt6_next =3D 0x0, dn_next =3D 0x0}}}, fl =
=3D {oif
=3D 0, iif =3D 0, mark =3D 0, nl_u =3D {ip4_u =3D {daddr =3D 0, saddr =3D=
 0, tos =3D 0
'\000', scope =3D 0 '\000'}, ip6_u =3D {daddr =3D {in6_u =3D {
              u6_addr8 =3D '\000' <repeats 15 times>, u6_addr16 =3D {0, 0=
,
0, 0, 0, 0, 0, 0}, u6_addr32 =3D {0, 0, 0, 0}}}, saddr =3D {in6_u =3D
{u6_addr8 =3D '\000' <repeats 15 times>, u6_addr16 =3D {0, 0, 0, 0, 0, 0,=
 0,
0}, u6_addr32 =3D {0, 0, 0, 0}}}, flowlabel =3D 0}, dn_u =3D {
          daddr =3D 0, saddr =3D 0, scope =3D 0 '\000'}}, proto =3D 0 '\0=
00',
flags =3D 0 '\000', uli_u =3D {ports =3D {sport =3D 0, dport =3D 0}, icmp=
t =3D {type
=3D 0 '\000', code =3D 0 '\000'}, dnports =3D {sport =3D 0, dport =3D 0},=
 spi =3D 0,
mht =3D {type =3D 0 '\000'}}, secid =3D 0}, idev =3D 0x0,
    rt_genid =3D 0, rt_flags =3D 0, rt_type =3D 0, rt_dst =3D 0, rt_src =3D=
 0,
rt_iif =3D 0, rt_gateway =3D 0, rt_spec_dst =3D 0, peer =3D 0x0}, flags =3D=
 0,
designated_root =3D {prio =3D "\200", addr =3D "\000\016\216\031\356v"},
bridge_id =3D {prio =3D "\200", addr =3D "\000\016\216\031\356v"},
  root_path_cost =3D 0, max_age =3D 20000, hello_time =3D 2000, forward_d=
elay
=3D 15000, bridge_max_age =3D 20000, ageing_time =3D 300000, bridge_hello=
_time
=3D 2000, bridge_forward_delay =3D 15000, group_addr =3D
"\001\200\302\000\000", root_port =3D 0, stp_enabled =3D BR_KERNEL_STP,
  topology_change =3D 0 '\000', topology_change_detected =3D 0 '\000',
multicast_router =3D 1 '\001', multicast_disabled =3D 0 '\000',
hash_elasticity =3D 4, hash_max =3D 512, multicast_last_member_count =3D =
2,
multicast_startup_queries_sent =3D 2, multicast_startup_query_count =3D 2=
,
  multicast_last_member_interval =3D 1000, multicast_membership_interval =
=3D
260000, multicast_querier_interval =3D 255000, multicast_query_interval =3D=

125000, multicast_query_response_interval =3D 10000,
multicast_startup_query_interval =3D 31250, multicast_lock =3D {{rlock =3D=
 {
        raw_lock =3D {<No data fields>}}}}, mdb =3D 0x0, router_list =3D
{first =3D 0x0}, mglist =3D {first =3D 0x0}, multicast_router_timer =3D {=
entry =3D
{next =3D 0x0, prev =3D 0x0}, expires =3D 0, function =3D 0xd0cbf264
<br_multicast_local_router_expired>, data =3D 0, base =3D 0xc0579640},
  multicast_querier_timer =3D {entry =3D {next =3D 0x0, prev =3D 0x0}, ex=
pires =3D
0, function =3D 0xd0cbf264 <br_multicast_local_router_expired>, data =3D =
0,
base =3D 0xc0579640}, multicast_query_timer =3D {entry =3D {next =3D 0xd0=
a1f630,
prev =3D 0xc057a1a4}, expires =3D 1756782,
    function =3D 0xd0cc01e1 <br_multicast_query_expired>, data =3D
3469117440, base =3D 0xc0579640}, hello_timer =3D {entry =3D {next =3D
0xc0579f14, prev =3D 0xcfcb6e10}, expires =3D 1694000, function =3D 0xd0c=
bc75b
<br_hello_timer_expired>, data =3D 3469117440, base =3D 0xc0579640},
  tcn_timer =3D {entry =3D {next =3D 0x0, prev =3D 0x0}, expires =3D 0, f=
unction =3D
0xd0cbc6ce <br_tcn_timer_expired>, data =3D 3469117440, base =3D
0xc0579640}, topology_change_timer =3D {entry =3D {next =3D 0x0, prev =3D=

0x200200}, expires =3D 225844,
    function =3D 0xd0cbc42c <br_topology_change_timer_expired>, data =3D
3469117440, base =3D 0xc0579640}, gc_timer =3D {entry =3D {next =3D 0xcfc=
b6e10,
prev =3D 0xc0579f14}, expires =3D 1694000, function =3D 0xd0cb8d8f
<br_fdb_cleanup>, data =3D 3469117440, base =3D 0xc0579640},
  ifobj =3D 0xcfca1164}
(gdb) print ((struct net_bridge*) 0xcec68800)->mdb
$4 =3D (struct net_bridge_mdb_htable *) 0x0
(gdb) bt
#0  jhash_3words (mdb=3D0x0, dst=3D0) at include/linux/jhash.h:128
#1  jhash_1word (mdb=3D0x0, dst=3D0) at include/linux/jhash.h:140
#2  br_ip_hash (mdb=3D0x0, dst=3D0) at net/bridge/br_multicast.c:32
#3  br_mdb_ip_get (mdb=3D0x0, dst=3D0) at net/bridge/br_multicast.c:52
#4  0xd0cc0ec8 in br_multicast_leave_group (br=3D0xcec68800, port=3D<valu=
e
optimised out>, skb=3D0xcf00e580) at net/bridge/br_multicast.c:902
#5  br_multicast_ipv4_rcv (br=3D0xcec68800, port=3D<value optimised out>,=

skb=3D0xcf00e580) at net/bridge/br_multicast.c:1033
#6  br_multicast_rcv (br=3D0xcec68800, port=3D<value optimised out>,
skb=3D0xcf00e580) at net/bridge/br_multicast.c:1052
#7  0xd0cb9c06 in br_handle_frame_finish (skb=3D0xcf00e580) at
net/bridge/br_input.c:55
#8  0xd0cbea59 in NF_HOOK_THRESH (skb=3D0xcf00e580) at
include/linux/netfilter.h:206
#9  br_nf_pre_routing_finish (skb=3D0xcf00e580) at
net/bridge/br_netfilter.c:420
#10 0xd0cbf015 in NF_HOOK_THRESH (hook=3D<value optimised out>,
skb=3D0xcf00e580, in=3D<value optimised out>, out=3D0x0, okfn=3D0xd0cb9ba=
d
<br_handle_frame_finish>) at include/linux/netfilter.h:206
#11 NF_HOOK (hook=3D<value optimised out>, skb=3D0xcf00e580, in=3D<value
optimised out>, out=3D0x0, okfn=3D0xd0cb9bad <br_handle_frame_finish>) at=

include/linux/netfilter.h:228
#12 br_nf_pre_routing (hook=3D<value optimised out>, skb=3D0xcf00e580,
in=3D<value optimised out>, out=3D0x0, okfn=3D0xd0cb9bad
<br_handle_frame_finish>) at net/bridge/br_netfilter.c:610
#13 0xc0377247 in ?? ()



// commit //
commit eb1d16414339a6e113d89e2cca2556005d7ce919
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Feb 27 19:41:45 2010 +0000

    bridge: Add core IGMP snooping support

    This patch adds the core functionality of IGMP snooping support
    without actually hooking it up.  So this patch should be a no-op
    as far as the bridge's external behaviour is concerned.

    All the new code and data is controlled by the Kconfig option
    BRIDGE_IGMP_SNOOPING.  A run-time toggle is also available.

    The multicast switching is done using an hash table that is
    lockless on the read-side through RCU.  On the write-side the
    new multicast_lock is used for all operations.  The hash table
    supports dynamic growth/rehashing.

    The hash table will be rehashed if any chain length exceeds a
    preset limit.  If rehashing does not reduce the maximum chain
    length then snooping will be disabled.

    These features may be added in future (in no particular order):

    * IGMPv3 source support
    * Non-querier router detection
    * IPv6

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>



--------------010108080208000901000501
Content-Type: text/x-patch;
 name="linux-next-20100313-bridge-multicast.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="linux-next-20100313-bridge-multicast.diff"

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 12ce1ea..85ca985 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -899,6 +899,8 @@ static void br_multicast_leave_group(struct net_bridg=
e *br,
 		goto out;
=20
 	mdb =3D br->mdb;
+	if (!mdb)
+		goto out;
 	mp =3D br_mdb_ip_get(mdb, group);
 	if (!mp)
 		goto out;


--------------010108080208000901000501--

--------------enig30C71BC04313DF95D331E089
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkucSecACgkQ+6sI4XSM4u2z8wCeNel9pTLH7oTbW8EwCfvSkzrH
I8UAnjPsDiOSqqMpEC9PgIKMSio6SsU1
=aweS
-----END PGP SIGNATURE-----

--------------enig30C71BC04313DF95D331E089--
