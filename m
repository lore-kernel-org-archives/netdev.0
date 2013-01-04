From: Tom Parkin <tparkin@katalix.com>
Subject: NULL pointer dereference in veth_stats_one
Date: Fri, 4 Jan 2013 10:59:56 +0000
Message-ID: <20130104105955.GA3663@raven>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DBIVS5p969aUjpLe"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49872 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164Ab3ADLAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 06:00:01 -0500
Received: from localhost (cpc28-brad20-2-0-cust174.17-1.cable.virginmedia.com [77.97.157.175])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tom)
	by mail.katalix.com (Postfix) with ESMTPSA id 24130A620B6
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2013 10:59:57 +0000 (GMT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DBIVS5p969aUjpLe
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi list,

I recently tripped over a NULL pointer dereference in the veth driver.
I'm running a 3.8.0_rc1 (updated from net-next git tree this morning)
on an Athlon 64 X2 machine running a 32 bit kernel.  To trigger the
oops I simply created a veth interface as follows:

        ip link add name ve0 type veth peer name ve1

I did a little digging in the git history and I note that veth
statistics changed a little with commit 2681128f0ced8aa4.  I tried
reverting that commit in my tree, which made the oops go away again.

Thanks,
Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="veth-koops.txt"
Content-Transfer-Encoding: quoted-printable

[  266.169346] BUG: unable to handle kernel NULL pointer dereference at 000=
002c0
[  266.172053] IP: [<f8177388>] veth_stats_one.isra.5+0x38/0xd0 [veth]
[  266.172053] *pde =3D 00000000=20
[  266.172053] Oops: 0000 [#1] SMP=20
[  266.172053] Modules linked in: veth bridge stp llc l2tp_ip6 l2tp_ip l2tp=
_ppp pppox l2tp_eth l2tp_netlink l2tp_core radeon k9
[  266.193196] Pid: 1544, comm: ip Not tainted 3.8.0-rc1-tpdev-23-lockdep+ =
#29 Gigabyte Technology Co., Ltd. GA-MA69VM-S2/GA-M2
[  266.193196] EIP: 0060:[<f8177388>] EFLAGS: 00010297 CPU: 1
[  266.193196] EIP is at veth_stats_one.isra.5+0x38/0xd0 [veth]
[  266.193196] EAX: 00000000 EBX: f47cd86c ECX: 00000000 EDX: 00000000
[  266.193196] ESI: f47cd874 EDI: 00000000 EBP: f47cd864 ESP: f47cd840
[  266.193196]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  266.193196] CR0: 8005003b CR2: 000002c0 CR3: 34456000 CR4: 000007d0
[  266.193196] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  266.193196] DR6: ffff0ff0 DR7: 00000400
[  266.193196] Process ip (pid: 1544, ti=3Df47cc000 task=3Df732bf00 task.ti=
=3Df47cc000)
[  266.193196] Stack:
[  266.193196]  f47cd86c 00000003 00000000 00000000 00000000 00000000 f47cd=
8d4 f345e000
[  266.193196]  f47cd98c f47cd888 f817746d 00000000 00000000 00000000 00000=
000 c13083d2
[  266.193196]  f47cd8d4 f345e000 f47cd8a0 c14fa6ab f8178040 f345f800 fffff=
fa6 f345f8bc
[  266.193196] Call Trace:
[  266.193196]  [<f817746d>] veth_get_stats64+0x4d/0x80 [veth]
[  266.193196]  [<c13083d2>] ? __nla_reserve+0x42/0x60
[  266.193196]  [<c14fa6ab>] dev_get_stats+0x5b/0x100
[  266.193196]  [<c15111e9>] rtnl_fill_ifinfo+0x4d9/0xc30
[  266.193196]  [<c109e2e6>] ? mark_held_locks+0x66/0xf0
[  266.193196]  [<c1155572>] ? __kmalloc_track_caller+0xc2/0x1e0
[  266.193196]  [<c14f201e>] ? __alloc_skb+0x5e/0x260
[  266.193196]  [<c14f1f39>] ? __kmalloc_reserve.isra.58+0x29/0x70
[  266.193196]  [<c14f202d>] ? __alloc_skb+0x6d/0x260
[  266.193196]  [<c15128ed>] rtmsg_ifinfo+0x7d/0x100
[  266.193196]  [<c1512a28>] rtnl_configure_link+0x78/0xa0
[  266.193196]  [<f8177633>] veth_newlink+0x143/0x30c [veth]
[  266.193196]  [<c109e2e6>] ? mark_held_locks+0x66/0xf0
[  266.193196]  [<f81774f0>] ? veth_open+0x50/0x50 [veth]
[  266.193196]  [<c1512edc>] rtnl_newlink+0x48c/0x540
[  266.193196]  [<c1512b5f>] ? rtnl_newlink+0x10f/0x540
[  266.193196]  [<c1512a50>] ? rtnl_configure_link+0xa0/0xa0
[  266.193196]  [<c1512693>] rtnetlink_rcv_msg+0x153/0x2a0
[  266.193196]  [<c160cbea>] ? mutex_lock_nested+0x21a/0x2e0
[  266.193196]  [<c150f534>] ? rtnl_lock+0x14/0x20
[  266.193196]  [<c1512540>] ? __rtnl_unlock+0x20/0x20
[  266.193196]  [<c15294be>] netlink_rcv_skb+0x8e/0xb0
[  266.193196]  [<c150f55c>] rtnetlink_rcv+0x1c/0x30
[  266.193196]  [<c1528e7d>] netlink_unicast+0x17d/0x1f0
[  266.193196]  [<c1529114>] netlink_sendmsg+0x224/0x390
[  266.193196]  [<c14e86c1>] sock_sendmsg+0xd1/0xf0
[  266.193196]  [<c1135b89>] ? might_fault+0x89/0x90
[  266.193196]  [<c12fa932>] ? _copy_from_user+0x42/0x60
[  266.193196]  [<c14f5c14>] ? verify_iovec+0x44/0xb0
[  266.193196]  [<c14e95d2>] __sys_sendmsg+0x262/0x270
[  266.193196]  [<c1073e4f>] ? sched_clock_cpu+0xcf/0x150
[  266.193196]  [<c109c02b>] ? trace_hardirqs_off+0xb/0x10
[  266.193196]  [<c1073f35>] ? local_clock+0x65/0x70
[  266.193196]  [<c109c69c>] ? lock_release_holdtime.part.23+0xbc/0xf0
[  266.193196]  [<c10a15ed>] ? lock_release_non_nested+0x29d/0x2e0
[  266.193196]  [<c1073f35>] ? local_clock+0x65/0x70
[  266.193196]  [<c1178ab1>] ? fget_light+0x371/0x450
[  266.193196]  [<c14eaccb>] sys_sendmsg+0x3b/0x60
[  266.193196]  [<c14eb373>] sys_socketcall+0x283/0x2e0
[  266.193196]  [<c16103e0>] ? restore_all+0xf/0xf
[  266.193196]  [<c1613c90>] ? __do_page_fault+0x4e0/0x4e0
[  266.193196]  [<c12fa548>] ? trace_hardirqs_on_thunk+0xc/0x10
[  266.193196]  [<c1617b8d>] sysenter_do_call+0x12/0x38
[  266.193196] Code: 00 c7 00 00 00 00 00 89 cf 89 c3 c7 40 04 00 00 00 00 =
89 d6 b9 ff ff ff ff c7 02 00 00 00 00 c7 42 04 00 b
[  266.193196] EIP: [<f8177388>] veth_stats_one.isra.5+0x38/0xd0 [veth] SS:=
ESP 0068:f47cd840
[  266.193196] CR2: 00000000000002c0
[  266.553774] ---[ end trace fff0ac235458be49 ]---

--uAKRQypu60I7Lcqm--

--DBIVS5p969aUjpLe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJQ5rYrAAoJEJSMBmUKuovQO+oH/i7UigFyX14Sq4sOhooK+yav
9kRrQaBrGhEQnr0BCwKxwuNu5q9ZKgmmzXim16GhXPCGUj1lqF5tB0F7jXnp/RoC
nVdhMWMQKR3GfAG/QnN298qkrTm7FSrHIYfe2Ae77qdX/oUVG6zzyB+BjpSZPDxU
e2neZ4zynu+fqAqhXASl8scRHry43DA/3zWeTkM9/sNpfjKrGE+oBAGP4lwO8+LH
CsihdCtOnGdluhlpQ+ONAICKalQQk0SD5SIFWd7tEPK1TjG8DvE/6/TasLS5Qqez
AOflt6Xt4a4dt+H4Qbx4Gm3i7N+Z9XbPppVhBIlIdS37yV9jO9Us0+bZ/RQj2LA=
=fr1c
-----END PGP SIGNATURE-----

--DBIVS5p969aUjpLe--
