From: Jose M Calhariz <jose.calhariz@netvisao.pt>
Subject: page allocation failure. order:2, mode:0x204020 while enabling Jumbo
 frame
Date: Fri, 5 Sep 2014 19:44:00 +0100
Message-ID: <20140905184400.GA27606@calhariz.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
To: netdev@vger.kernel.org, ns-list@dsi.ist.utl.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from front3.netvisao.pt ([213.228.128.91]:47767 "HELO
	front3.netvisao.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750776AbaIESun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 14:50:43 -0400
Received: from av-out1.netvisao.pt (localhost [127.0.0.1])
	by av-out1.netvisao.pt (Postfix) with ESMTP id 6EA5712FFBC
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2014 19:44:01 +0100 (WEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi

I have a Debian 7.0 server currently running kernel 3.16 from
kernel.org.  This server is a client of nfsv3, iSCSI and use dmcrypt.
When and only when enabling Jumbo Frames I get "page allocation
failure: order:2, mode:0x204020", in the end of the email is a stack
trace from this error.

Sometimes the rate of "page allocation failure" is very big or the
network stack stops, making the machine "network unreachable" to a
nagios server.


Sep  5 10:51:14 XXXXXX kernel: warn_alloc_failed: 5 callbacks suppressed
Sep  5 10:51:14 XXXXXX kernel: kworker/0:1: page allocation failure: order:=
2, mode:0x204020
Sep  5 10:51:14 XXXXXX kernel: CPU: 0 PID: 6178 Comm: kworker/0:1 Tainted: =
G          I   3.16.0-dsi #9
Sep  5 10:51:14 XXXXXX kernel: Hardware name: Dell Inc. PowerEdge R410/01V6=
48, BIOS 1.12.0 07/30/2013
Sep  5 10:51:14 XXXXXX kernel: Workqueue: kcryptd kcryptd_crypt [dm_crypt]
Sep  5 10:51:14 XXXXXX kernel: 0000000000000000 0000000000000000 ffffffff81=
4fd161 0000000000204020
Sep  5 10:51:14 XXXXXX kernel: ffffffff811395d2 ffff88032fffac00 ffffffff81=
8b04b0 0000000000000003
Sep  5 10:51:14 XXXXXX kernel: 0000000000000018 000000012fffac18 ffff8801af=
fff0a8 0000000000000096
Sep  5 10:51:14 XXXXXX kernel: Call Trace:
Sep  5 10:51:14 XXXXXX kernel: <IRQ>  [<ffffffff814fd161>] ? dump_stack+0x4=
1/0x51
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff811395d2>] ? warn_alloc_failed+0xf=
2/0x150
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8113d930>] ? __alloc_pages_nodemas=
k+0x8e0/0xb40
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8118355a>] ? kmem_getpages+0x5a/0x=
110
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8118522f>] ? fallback_alloc+0x1cf/=
0x220
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019ef1d>] ? bnx2x_alloc_rx_data.i=
sra.75+0x5d/0x1e0 [bnx2x]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff811854bc>] ? __kmalloc+0x19c/0x1f0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019ef1d>] ? bnx2x_alloc_rx_data.i=
sra.75+0x5d/0x1e0 [bnx2x]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019f894>] ? bnx2x_rx_int+0x7f4/0x=
1790 [bnx2x]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814005e8>] ? skb_release_head_stat=
e+0x48/0xf0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814006f9>] ? __kfree_skb+0x9/0xa0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81461f6d>] ? tcp_schedule_loss_pro=
be+0x12d/0x1a0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa01a25a8>] ? bnx2x_poll+0xe8/0x3b0=
 [bnx2x]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8140fc18>] ? net_rx_action+0x138/0=
x240
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8106af4f>] ? __do_softirq+0xdf/0x2=
70
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8106b315>] ? irq_exit+0x95/0xa0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81015701>] ? do_IRQ+0x61/0x110
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81503aed>] ? common_interrupt+0x6d=
/0x6d
Sep  5 10:51:14 XXXXXX kernel: <EOI>  [<ffffffffa0378c10>] ? _aesni_enc1+0x=
5c/0xac [aesni_intel]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa0379170>] ? aesni_cbc_enc+0x20/0x=
40 [aesni_intel]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa037ab24>] ? cbc_encrypt+0x74/0xd0=
 [aesni_intel]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa02270fe>] ? __ablk_encrypt+0x3e/0=
x50 [ablk_helper]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa069641b>] ? crypt_convert+0x20b/0=
x460 [dm_crypt]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa069682b>] ? kcryptd_crypt+0x1bb/0=
x400 [dm_crypt]
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81080adb>] ? process_one_work+0x16=
b/0x400
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81081184>] ? worker_thread+0x114/0=
x510
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814ff3f8>] ? __schedule+0x2c8/0x760
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81081070>] ? rescuer_thread+0x2c0/=
0x2c0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff810876cc>] ? kthread+0xbc/0xe0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81087610>] ? flush_kthread_worker+=
0x80/0x80
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81502f3c>] ? ret_from_fork+0x7c/0x=
b0
Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81087610>] ? flush_kthread_worker+=
0x80/0x80
Sep  5 10:51:14 XXXXXX kernel: Mem-Info:
Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal per-cpu:
Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd: 141
Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd: 178
Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd: 169
Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd: 181
Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA per-cpu:
Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:    0, btch:   1 usd:   0
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32 per-cpu:
Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:  51
Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd:  36
Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:  51
Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:  59
Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal per-cpu:
Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:  95
Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd: 100
Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:  95
Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd:   0
Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:  79
Sep  5 10:51:14 XXXXXX kernel: active_anon:391978 inactive_anon:217234 isol=
ated_anon:0
Sep  5 10:51:14 XXXXXX kernel: active_file:405690 inactive_file:251497 isol=
ated_file:0
Sep  5 10:51:14 XXXXXX kernel: unevictable:2192 dirty:0 writeback:0 unstabl=
e:0
Sep  5 10:51:14 XXXXXX kernel: free:482104 slab_reclaimable:827503 slab_unr=
eclaimable:171240
Sep  5 10:51:14 XXXXXX kernel: mapped:3469 shmem:99 pagetables:2164 bounce:0
Sep  5 10:51:14 XXXXXX kernel: free_cma:0
Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal free:801464kB min:528080kB low=
:660100kB high:792120kB active_anon:1161624kB inactive_anon:387580kB active=
_file:534424kB inactive_file:291488kB unevictable:4940kB isolated(anon):0kB=
 isolated(file):0kB present:6291456kB managed:6203092kB mlocked:4944kB dirt=
y:0kB
+writeback:0kB mapped:5116kB shmem:124kB slab_reclaimable:1923736kB slab_un=
reclaimable:386892kB kernel_stack:4368kB pagetables:5768kB unstable:0kB bou=
nce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:47 all_unreclaimable? =
no
Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 0 0
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA free:15896kB min:1352kB low:1688k=
B high:2028kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_fi=
le:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15980k=
B managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
+slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0k=
B unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 al=
l_unreclaimable? yes
Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 3224 5952 5952
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32 free:804396kB min:281328kB low:=
351660kB high:421992kB active_anon:240284kB inactive_anon:288392kB active_f=
ile:558572kB inactive_file:412684kB unevictable:1972kB isolated(anon):0kB i=
solated(file):0kB present:3378660kB managed:3304628kB mlocked:1972kB dirty:=
0kB writeback:0kB
+mapped:4144kB shmem:204kB slab_reclaimable:618324kB slab_unreclaimable:133=
696kB kernel_stack:1168kB pagetables:1512kB unstable:0kB bounce:0kB free_cm=
a:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 2727 2727
Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal free:306660kB min:237808kB low=
:297260kB high:356712kB active_anon:166004kB inactive_anon:192964kB active_=
file:529764kB inactive_file:301816kB unevictable:1856kB isolated(anon):0kB =
isolated(file):0kB present:2883584kB managed:2793404kB mlocked:1856kB dirty=
:0kB writeback:0kB
+mapped:4616kB shmem:68kB slab_reclaimable:767952kB slab_unreclaimable:1643=
72kB kernel_stack:1312kB pagetables:1376kB unstable:0kB bounce:0kB free_cma=
:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 0 0
Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal: 186511*4kB (UEM) 5585*8kB (UE=
M) 421*16kB (UM) 1*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048k=
B 1*4096kB (R) =3D 801588kB
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA: 0*4kB 1*8kB (U) 1*16kB (U) 0*32k=
B 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*40=
96kB (M) =3D 15896kB
Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32: 97773*4kB (EM) 49708*8kB (EM) =
721*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096=
kB (R) =3D 804388kB
Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal: 48558*4kB (EM) 13544*8kB (M) =
0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB (R)=
 =3D 306680kB
Sep  5 10:51:14 XXXXXX kernel: Node 0 hugepages_total=3D0 hugepages_free=3D=
0 hugepages_surp=3D0 hugepages_size=3D2048kB
Sep  5 10:51:14 XXXXXX kernel: Node 1 hugepages_total=3D0 hugepages_free=3D=
0 hugepages_surp=3D0 hugepages_size=3D2048kB
Sep  5 10:51:14 XXXXXX kernel: 658273 total pagecache pages
Sep  5 10:51:14 XXXXXX kernel: 37 pages in swap cache
Sep  5 10:51:14 XXXXXX kernel: Swap cache stats: add 499, delete 462, find =
7/10
Sep  5 10:51:14 XXXXXX kernel: Free swap  =3D 37456928kB
Sep  5 10:51:14 XXXXXX kernel: Total swap =3D 37458864kB
Sep  5 10:51:14 XXXXXX kernel: 3142420 pages RAM
Sep  5 10:51:14 XXXXXX kernel: 0 pages HighMem/MovableOnly
Sep  5 10:51:14 XXXXXX kernel: 22545 pages reserved
Sep  5 10:51:14 XXXXXX kernel: 0 pages hwpoisoned



--=20
--
	Cita=E7=E3o: ato de repetir de modo errado as palavras alheias.
		--  Ambrose Bierce; jornalista e cientista americano.

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJUCgRwAAoJEDSKd41ohe+P1K4P/2TVpSv8Y9hPvj4Gjp/hOlXk
9kZQZe1mDmw6dhsuRz2Gy2aTA8oKCA4HMpGV9pNoSszGYOViKw2ngLrM1SbH35TF
AY589tt2dAxH/xMP0n26j1Rw+y7ItGEwpJspGET4I1Fg/rkgj50IZmh1CwU+77Hp
QjG9NkNA0Z95FPxSqN/JLw/Ae4jqzFsQrk93H778jLf0G8x1AG2A1kzYBd0g4vkB
Agh3etnGsLvnSkirI381VrnSFY7o0cHXx1k6MqAOO9eUOREWv77G43zEzaIW8R0E
23qetmb36MvlUuLH7TpqVzlt5THj64uToAzrXCOTv6f2hXb403reOEAwRXI1H/Lg
Dz0ODid3h/QhMGJSVQPKmOSEnJnphaVbQHbjyF8I0XzU1/mzaiyIu0zKKiLK+YbI
9GzZhnkKD67U+oIY+umvc8PolJPakzJr7ysZY+NKbN2NG/7LDepZQ5+ySC79Wo+c
COZh4SV70K/EaUut3fYQnz8xHzF/zqkTEv5lTao7xHtpTj+2UYpKQmPtXtQaUt+c
mHZTBlk8nx7Aqur6Efn+AqOoAgMnHDQetz3iZqBPlkJsRrGeiqboZr69BTDcDL/2
K8WKvee8wFyIZBBQ7mOGL8GwgiYbj7Te33EMputrT8TWqSAS4dq7qSaM/CeOs6ze
g1jwZrzrOalfG+Kpc9x/
=09C+
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--
