From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: kernel stack  trace using conntrack
Date: Tue, 16 Feb 2010 12:15:28 +0100
Message-ID: <1266318928.3045.38.camel@edumazet-laptop>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>
	 <1266313889.3045.1.camel@edumazet-laptop>
	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ramblewski David <David.Ramblewski@atosorigin.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 16 f=C3=A9vrier 2010 =C3=A0 11:25 +0100, Ramblewski David a =C3=
=A9crit :
> Here it is:
>=20
> [root@obench03s ~]# uname -a
> Linux obench03s 2.6.32.8 #1 SMP PREEMPT Wed Feb 10 17:32:16 CET 2010 =
i686 i686 i386 GNU/Linux
>=20
> [root@obench03s ~]# lsmod
> Module                  Size  Used by
> nf_conntrack_netlink     9810  0
> nf_conntrack           50283  1 nf_conntrack_netlink
> bonding                69153  0
> usbhid                 14557  0
> ipmi_si                29902  0
> rtc_cmos                7175  0
> bnx2                   53497  0
> hpwdt                   5548  0
> rtc_core               11461  1 rtc_cmos
> rtc_lib                 2022  1 rtc_core
> hpilo                   6051  0
> ipmi_msghandler        27670  1 ipmi_si
> ehci_hcd               27584  0
> uhci_hcd               16357  0
> usbcore               120714  4 usbhid,ehci_hcd,uhci_hcd
> dm_mod                 49320  0
> [root@obench03s ~]#
>=20
>=20
> [root@obench03s ~]# iptables --version
> iptables v1.4.0
> [root@obench03s ~]# iptables -L
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> [root@obench03s ~]# iptables -L -t nat
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain POSTROUTING (policy ACCEPT)
> target     prot opt source               destination
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> [root@obench03s ~]# conntrack -L
> udp      17 27 src=3D10.24.230.151 dst=3D10.26.103.28 sport=3D510 dpo=
rt=3D516 packets=3D5 bytes=3D295 [UNREPLIED] src=3D10.26.103.28 dst=3D1=
0.24.230.151 sport=3D516 dport=3D510 packets=3D0 bytes=3D0 mark=3D0 sec=
mark=3D0 use=3D2
> tcp      6 299 ESTABLISHED src=3D10.26.103.28 dst=3D10.28.64.65 sport=
=3D22 dport=3D53497 packets=3D89 bytes=3D8628 src=3D10.28.64.65 dst=3D1=
0.26.103.28 sport=3D53497 dport=3D22 packets=3D127 bytes=3D10396 [ASSUR=
ED] mark=3D0 secmark=3D0 use=3D2
> udp      17 21 src=3D127.0.0.1 dst=3D127.0.0.1 sport=3D32070 dport=3D=
161 packets=3D6 bytes=3D492 [UNREPLIED] src=3D127.0.0.1 dst=3D127.0.0.1=
 sport=3D161 dport=3D32070 packets=3D0 bytes=3D0 mark=3D0 secmark=3D0 u=
se=3D2
> conntrack v0.9.14 (conntrack-tools): 3 flow entries have been shown.
> [root@obench03s ~]#
>=20
> David

OK thanks David, I reproduced the problem on latest net-next-2.6 tree
too. I wonder why nobody hit this before.


[352468.556484] ------------[ cut here ]------------
[352468.556511] WARNING: at net/netfilter/nf_conntrack_extend.c:82
__nf_ct_ext_add+0x1c2/0x1e0 [nf_conntrack]()
[352468.556559] Hardware name: ProLiant BL460c G1
[352468.556582] Modules linked in: nf_defrag_ipv4 nf_conntrack_netlink
nf_conntrack sch_hfsc sch_sfq ipmi_devintf ipmi_si ipmi_msghandler hpil=
o
bonding [last unloaded: nf_conntrack_ipv4]
[352468.556675] Pid: 18852, comm: conntrack Tainted: G        W
2.6.33-rc5-02754-g0ea034c-dirty #545
[352468.556721] Call Trace:
[352468.556742]  [<c054d45f>] ? printk+0x1d/0x26
[352468.556767]  [<c023bbc2>] warn_slowpath_common+0x72/0xa0
[352468.556795]  [<fee75e42>] ? __nf_ct_ext_add+0x1c2/0x1e0
[nf_conntrack]
[352468.556825]  [<fee75e42>] ? __nf_ct_ext_add+0x1c2/0x1e0
[nf_conntrack]
[352468.556854]  [<c023bc0a>] warn_slowpath_null+0x1a/0x20
[352468.556882]  [<fee75e42>] __nf_ct_ext_add+0x1c2/0x1e0 [nf_conntrack=
]
[352468.556911]  [<fee70dcc>] ? nf_conntrack_alloc+0x10c/0x1a0
[nf_conntrack]
[352468.556940]  [<feecaf59>] ctnetlink_create_conntrack+0x339/0x360
[nf_conntrack_netlink]
[352468.556987]  [<feeca26b>] ? ctnetlink_parse_tuple+0x14b/0x1c0
[nf_conntrack_netlink]
[352468.557039]  [<fee6fd60>] ? __nf_conntrack_find+0x70/0x100
[nf_conntrack]
[352468.557068]  [<feecb090>] ctnetlink_new_conntrack+0x110/0x680
[nf_conntrack_netlink]
[352468.557113]  [<c04d93b5>] nfnetlink_rcv_msg+0x125/0x180
[352468.557140]  [<c054ec57>] ? __mutex_lock_slowpath+0x197/0x230
[352468.557167]  [<c04d9290>] ? nfnetlink_rcv_msg+0x0/0x180
[352468.557194]  [<c04d5896>] netlink_rcv_skb+0x96/0xc0
[352468.557219]  [<c04d927c>] nfnetlink_rcv+0x1c/0x30
[352468.557245]  [<c04d5545>] netlink_unicast+0x255/0x2a0
[352468.557274]  [<c04d5d3f>] netlink_sendmsg+0x1af/0x2b0
[352468.557300]  [<c04a86ec>] sock_sendmsg+0xac/0xe0
[352468.559358]  [<c029d042>] ? find_get_page+0x22/0xd0
[352468.559385]  [<c029d9dc>] ? filemap_fault+0x8c/0x3c0
[352468.559410]  [<c04a905a>] sys_sendto+0xaa/0xd0
[352468.559436]  [<c02b3780>] ? __do_fault+0x370/0x470
[352468.559462]  [<c02b54d9>] ? handle_mm_fault+0x1d9/0x7d0
[352468.559488]  [<c04aa245>] sys_socketcall+0x195/0x280
[352468.559514]  [<c0202c50>] sysenter_do_call+0x12/0x26
[352468.559539] ---[ end trace 6ecb842e4e35a653 ]---

Could you try following patch ?

Thanks

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index 0ffe689..d2657aa 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -923,7 +923,7 @@ ctnetlink_change_status(struct nf_conn *ct, const s=
truct nlattr * const cda[])
 	unsigned int status =3D ntohl(nla_get_be32(cda[CTA_STATUS]));
 	d =3D ct->status ^ status;
=20
-	if (d & (IPS_EXPECTED|IPS_CONFIRMED|IPS_DYING))
+	if (d & (IPS_EXPECTED|IPS_DYING))
 		/* unchangeable */
 		return -EBUSY;
=20
@@ -938,7 +938,7 @@ ctnetlink_change_status(struct nf_conn *ct, const s=
truct nlattr * const cda[])
 	/* Be careful here, modifying NAT bits can screw up things,
 	 * so don't let users modify them directly if they don't pass
 	 * nf_nat_range. */
-	ct->status |=3D status & ~(IPS_NAT_DONE_MASK | IPS_NAT_MASK);
+	ct->status |=3D status & ~(IPS_NAT_DONE_MASK | IPS_NAT_MASK | IPS_CON=
=46IRMED);
 	return 0;
 }
=20
@@ -1193,7 +1193,6 @@ ctnetlink_create_conntrack(const struct nlattr * =
const cda[],
 	ct->timeout.expires =3D ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
=20
 	ct->timeout.expires =3D jiffies + ct->timeout.expires * HZ;
-	ct->status |=3D IPS_CONFIRMED;
=20
 	rcu_read_lock();
  	if (cda[CTA_HELP]) {
@@ -1296,6 +1295,7 @@ ctnetlink_create_conntrack(const struct nlattr * =
const cda[],
 	}
=20
 	add_timer(&ct->timeout);
+	ct->status |=3D IPS_CONFIRMED;
 	nf_conntrack_hash_insert(ct);
 	rcu_read_unlock();
=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
