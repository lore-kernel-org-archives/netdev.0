From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: huh, entered softirq 3 NET_RX 082db810 preempt_count 00000101, exited
 with fffefc05?
Date: Fri, 26 Oct 2012 22:34:28 +0200
Message-ID: <508AF3D4.4020707@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:36156 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756911Ab2JZUeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 16:34:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At a user mode linux image (unstable Gentoo) I experienced a hang
(100% CPU of the linux process), no reaction anymore.

The last lines in the syslog of the UML gave:

=2E..
Oct 26 22:18:07 n22_uml kernel: Virtual console 6 assigned device '/dev=
/pts/5'                                              =20
Oct 26 22:18:07 n22_uml kernel: Virtual console 4 assigned device '/dev=
/pts/6'                                                             =20
Oct 26 22:18:07 n22_uml kernel: Virtual console 5 assigned device '/dev=
/pts/8'                                                             =20
Oct 26 22:18:07 n22_uml kernel: Virtual console 3 assigned device '/dev=
/pts/9'                                                             =20
Oct 26 22:18:07 n22_uml kernel: Virtual console 2 assigned device '/dev=
/pts/10'                                                            =20
Oct 26 22:18:07 n22_uml kernel: Virtual console 1 assigned device '/dev=
/pts/11'                                                            =20
Oct 26 22:19:05 n22_uml kernel: ------------[ cut here ]------------   =
                                                                    =20
Oct 26 22:19:05 n22_uml kernel: WARNING: at kernel/softirq.c:160 local_=
bh_enable+0x8f/0xa0()                                               =20
Oct 26 22:19:05 n22_uml kernel: 384fa37c:  [<0836bc48>] dump_stack+0x22=
/0x24                                                               =20
Oct 26 22:19:05 n22_uml kernel: 384fa394:  [<0807fc2a>] warn_slowpath_c=
ommon+0x5a/0x80                                                     =20
Oct 26 22:19:05 n22_uml kernel: 384fa3bc:  [<0807fd03>] warn_slowpath_n=
ull+0x23/0x30                                                       =20
Oct 26 22:19:05 n22_uml kernel: 384fa3cc:  [<0808733f>] local_bh_enable=
+0x8f/0xa0                                                             =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa3e0:  [<082da6f8>] dev_queue_xmit+=
0xe8/0x270                                                             =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa410:  [<082fd15f>] ip_finish_outpu=
t+0x1af/0x370                                                          =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa444:  [<082fd373>] ip_output+0x53/=
0x60                                                                   =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa45c:  [<082fc243>] ip_local_out+0x=
23/0x30                                                                =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa46c:  [<082fc384>] ip_build_and_se=
nd_pkt+0x134/0x1f0                                                     =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa4a8:  [<08319dc0>] tcp_v4_conn_req=
uest+0x7c0/0xcc0                                                       =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa5ac:  [<08310c9c>] tcp_rcv_state_p=
rocess+0x1bc/0xd40                                                     =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa618:  [<08317a7d>] tcp_v4_do_rcv+0=
x8d/0x270                                                              =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa65c:  [<0831ab36>] tcp_v4_rcv+0x74=
6/0x860                                                                =
                  =20
Oct 26 22:19:05 n22_uml kernel: 384fa6a4:  [<082f8696>] ip_local_delive=
r+0x76/0x1d0
Oct 26 22:19:05 n22_uml kernel: 384fa6c4:  [<082f8a98>] ip_rcv+0x2a8/0x=
4a0
Oct 26 22:19:05 n22_uml kernel: 384fa6f0:  [<082d7a34>] __netif_receive=
_skb+0x254/0x550
Oct 26 22:19:05 n22_uml kernel: 384fa738:  [<082d7d99>] process_backlog=
+0x69/0x100
Oct 26 22:19:05 n22_uml kernel: 384fa758:  [<082db88c>] net_rx_action+0=
x7c/0x140
Oct 26 22:19:05 n22_uml kernel: 384fa77c:  [<08087145>] __do_softirq+0x=
a5/0x170
Oct 26 22:19:05 n22_uml kernel: 384fa7b8:  [<080872a5>] do_softirq+0x55=
/0x60
Oct 26 22:19:05 n22_uml kernel: 384fa7cc:  [<080874f5>] irq_exit+0x85/0=
x90
Oct 26 22:19:05 n22_uml kernel: 384fa7dc:  [<0805ef3a>] do_IRQ+0x2a/0x4=
0
Oct 26 22:19:05 n22_uml kernel: 384fa7ec:  [<0805efab>] sigio_handler+0=
x5b/0x80
Oct 26 22:19:05 n22_uml kernel: 384fa804:  [<08073b87>] sig_handler_com=
mon+0x57/0xe0
Oct 26 22:19:05 n22_uml kernel: 384faa88:  [<08073b10>] unblock_signals=
+0x50/0x70
Oct 26 22:19:05 n22_uml kernel: 384faa94:  [<08073ca0>] set_signals+0x3=
0/0x40
Oct 26 22:19:05 n22_uml kernel: 384faaa0:  [<08087296>] do_softirq+0x46=
/0x60
Oct 26 22:19:05 n22_uml kernel: 384faab4:  [<08087329>] local_bh_enable=
+0x79/0xa0
Oct 26 22:19:05 n22_uml kernel: 384faac8:  [<082fd166>] ip_finish_outpu=
t+0x1b6/0x370
Oct 26 22:19:05 n22_uml kernel: 384faafc:  [<082fd373>] ip_output+0x53/=
0x60
Oct 26 22:19:05 n22_uml kernel: 384fab14:  [<082fc243>] ip_local_out+0x=
23/0x30
Oct 26 22:19:05 n22_uml kernel: 384fab24:  [<082fc55f>] ip_queue_xmit+0=
x11f/0x3a0
Oct 26 22:19:05 n22_uml kernel: 384fab6c:  [<08312de8>] tcp_transmit_sk=
b+0x3e8/0x890
Oct 26 22:19:05 n22_uml kernel: 384fabc8:  [<0831345d>] tcp_write_xmit+=
0xfd/0xa60
Oct 26 22:19:05 n22_uml kernel: 384fac28:  [<08313e68>] __tcp_push_pend=
ing_frames+0x38/0xa0
Oct 26 22:19:05 n22_uml kernel: 384fac40:  [<083044c9>] tcp_sendmsg+0x1=
29/0xe30
Oct 26 22:19:05 n22_uml kernel: 384facc4:  [<08328fdb>] inet_sendmsg+0x=
3b/0x60
Oct 26 22:19:05 n22_uml kernel: 384face0:  [<082c7dc4>] sock_aio_write+=
0x114/0x140
Oct 26 22:19:05 n22_uml kernel: 384fad50:  [<08103803>] do_sync_readv_w=
ritev+0x83/0xc0
Oct 26 22:19:05 n22_uml kernel: 384fadf4:  [<08103ab1>] do_readv_writev=
+0xb1/0x1c0
Oct 26 22:19:05 n22_uml kernel: 384fae6c:  [<08103c4c>] vfs_writev+0x3c=
/0x50
Oct 26 22:19:05 n22_uml kernel: 384fae7c:  [<08103d50>] sys_writev+0x50=
/0xa0
Oct 26 22:19:05 n22_uml kernel: 384faeac:  [<08062ec6>] handle_syscall+=
0xa6/0xb0
Oct 26 22:19:05 n22_uml kernel: 384faef4:  [<0807711f>] userspace+0x3ef=
/0x5a0
Oct 26 22:19:05 n22_uml kernel: 384fafec:  [<0805f8ec>] fork_handler+0x=
6c/0x70
Oct 26 22:19:05 n22_uml kernel: 384faffc:  [<00000000>] 0x0
Oct 26 22:19:05 n22_uml kernel:=20
Oct 26 22:19:05 n22_uml kernel: ---[ end trace bb507477e2c8dbef ]---
Oct 26 22:19:05 n22_uml kernel: ------------[ cut here ]------------
Oct 26 22:19:05 n22_uml kernel: WARNING: at net/core/skbuff.c:573 skb_r=
elease_head_state+0x89/0x90()
Oct 26 22:19:05 n22_uml kernel: 384fa314:  [<0836bc48>] dump_stack+0x22=
/0x24
Oct 26 22:19:05 n22_uml kernel: 384fa32c:  [<0807fc2a>] warn_slowpath_c=
ommon+0x5a/0x80
Oct 26 22:19:05 n22_uml kernel: 384fa354:  [<0807fd03>] warn_slowpath_n=
ull+0x23/0x30
Oct 26 22:19:05 n22_uml kernel: 384fa364:  [<082ce839>] skb_release_hea=
d_state+0x89/0x90
Oct 26 22:19:05 n22_uml kernel: 384fa37c:  [<082cf591>] __kfree_skb+0x1=
1/0xa0
Oct 26 22:19:05 n22_uml kernel: 384fa390:  [<082cf640>] consume_skb+0x2=
0/0x40
Oct 26 22:19:05 n22_uml kernel: 384fa39c:  [<08068b84>] uml_net_start_x=
mit+0x84/0x120
Oct 26 22:19:05 n22_uml kernel: 384fa3c0:  [<082da1a1>] dev_hard_start_=
xmit+0x1e1/0x420
Oct 26 22:19:05 n22_uml kernel: 384fa3fc:  [<082eeecb>] sch_direct_xmit=
+0x7b/0x140
Oct 26 22:19:05 n22_uml kernel: 384fa428:  [<082da6e0>] dev_queue_xmit+=
0xd0/0x270
Oct 26 22:19:05 n22_uml kernel: 384fa458:  [<082fd15f>] ip_finish_outpu=
t+0x1af/0x370
Oct 26 22:19:05 n22_uml kernel: 384fa48c:  [<082fd373>] ip_output+0x53/=
0x60
Oct 26 22:19:05 n22_uml kernel: 384fa4a4:  [<082fc243>] ip_local_out+0x=
23/0x30
Oct 26 22:19:05 n22_uml kernel: 384fa4b4:  [<082fc55f>] ip_queue_xmit+0=
x11f/0x3a0
Oct 26 22:19:05 n22_uml kernel: 384fa4fc:  [<08312de8>] tcp_transmit_sk=
b+0x3e8/0x890
Oct 26 22:19:05 n22_uml kernel: 384fa558:  [<08315d6a>] tcp_send_ack+0x=
da/0x120
Oct 26 22:19:05 n22_uml kernel: 384fa574:  [<0830a7b2>] __tcp_ack_snd_c=
heck+0x52/0x90
Oct 26 22:19:05 n22_uml kernel: 384fa588:  [<083114ac>] tcp_rcv_state_p=
rocess+0x9cc/0xd40
Oct 26 22:19:05 n22_uml kernel: 384fa5f4:  [<0831bd60>] tcp_child_proce=
ss+0xa0/0xd0
Oct 26 22:19:05 n22_uml kernel: 384fa618:  [<08317ba7>] tcp_v4_do_rcv+0=
x1b7/0x270
Oct 26 22:19:05 n22_uml kernel: 384fa65c:  [<0831ab36>] tcp_v4_rcv+0x74=
6/0x860
Oct 26 22:19:05 n22_uml kernel: 384fa6a4:  [<082f8696>] ip_local_delive=
r+0x76/0x1d0
Oct 26 22:19:05 n22_uml kernel: 384fa6c4:  [<082f8a98>] ip_rcv+0x2a8/0x=
4a0
Oct 26 22:19:05 n22_uml kernel: 384fa6f0:  [<082d7a34>] __netif_receive=
_skb+0x254/0x550
Oct 26 22:19:05 n22_uml kernel: 384fa738:  [<082d7d99>] process_backlog=
+0x69/0x100
Oct 26 22:19:05 n22_uml kernel: 384fa758:  [<082db88c>] net_rx_action+0=
x7c/0x140
Oct 26 22:19:05 n22_uml kernel: 384fa77c:  [<08087145>] __do_softirq+0x=
a5/0x170
Oct 26 22:19:05 n22_uml kernel: 384fa7b8:  [<080872a5>] do_softirq+0x55=
/0x60
Oct 26 22:19:05 n22_uml kernel: 384fa7cc:  [<080874f5>] irq_exit+0x85/0=
x90
Oct 26 22:19:05 n22_uml kernel: 384fa7dc:  [<0805ef3a>] do_IRQ+0x2a/0x4=
0
Oct 26 22:19:05 n22_uml kernel: 384fa7ec:  [<0805efab>] sigio_handler+0=
x5b/0x80
Oct 26 22:19:05 n22_uml kernel: 384fa804:  [<08073b87>] sig_handler_com=
mon+0x57/0xe0
Oct 26 22:19:05 n22_uml kernel: 384faa88:  [<08073b10>] unblock_signals=
+0x50/0x70
Oct 26 22:19:05 n22_uml kernel: 384faa94:  [<08073ca0>] set_signals+0x3=
0/0x40
Oct 26 22:19:05 n22_uml kernel: 384faaa0:  [<08087296>] do_softirq+0x46=
/0x60
Oct 26 22:19:05 n22_uml kernel: 384faab4:  [<08087329>] local_bh_enable=
+0x79/0xa0
Oct 26 22:19:05 n22_uml kernel: 384faac8:  [<082fd166>] ip_finish_outpu=
t+0x1b6/0x370
Oct 26 22:19:05 n22_uml kernel: 384faafc:  [<082fd373>] ip_output+0x53/=
0x60
Oct 26 22:19:05 n22_uml kernel: 384fab14:  [<082fc243>] ip_local_out+0x=
23/0x30
Oct 26 22:19:05 n22_uml kernel: 384fab24:  [<082fc55f>] ip_queue_xmit+0=
x11f/0x3a0
Oct 26 22:19:05 n22_uml kernel: 384fab6c:  [<08312de8>] tcp_transmit_sk=
b+0x3e8/0x890
Oct 26 22:19:05 n22_uml kernel: 384fabc8:  [<0831345d>] tcp_write_xmit+=
0xfd/0xa60
Oct 26 22:19:05 n22_uml kernel: 384fac28:  [<08313e68>] __tcp_push_pend=
ing_frames+0x38/0xa0
Oct 26 22:19:05 n22_uml kernel: 384fac40:  [<083044c9>] tcp_sendmsg+0x1=
29/0xe30
Oct 26 22:19:05 n22_uml kernel: 384facc4:  [<08328fdb>] inet_sendmsg+0x=
3b/0x60
Oct 26 22:19:05 n22_uml kernel: 384face0:  [<082c7dc4>] sock_aio_write+=
0x114/0x140
Oct 26 22:19:05 n22_uml kernel: 384fad50:  [<08103803>] do_sync_readv_w=
ritev+0x83/0xc0
Oct 26 22:19:05 n22_uml kernel: 384fadf4:  [<08103ab1>] do_readv_writev=
+0xb1/0x1c0
Oct 26 22:19:05 n22_uml kernel: 384fae6c:  [<08103c4c>] vfs_writev+0x3c=
/0x50
Oct 26 22:19:05 n22_uml kernel: 384fae7c:  [<08103d50>] sys_writev+0x50=
/0xa0
Oct 26 22:19:05 n22_uml kernel: 384faeac:  [<08062ec6>] handle_syscall+=
0xa6/0xb0
Oct 26 22:19:05 n22_uml kernel: 384faef4:  [<0807711f>] userspace+0x3ef=
/0x5a0
Oct 26 22:19:05 n22_uml kernel: 384fafec:  [<0805f8ec>] fork_handler+0x=
6c/0x70
Oct 26 22:19:05 n22_uml kernel: 384faffc:  [<00000000>] 0x0
Oct 26 22:19:05 n22_uml kernel:=20
Oct 26 22:19:05 n22_uml kernel: ---[ end trace bb507477e2c8dbf0 ]---
Oct 26 22:19:05 n22_uml kernel: huh, entered softirq 3 NET_RX 082db810 =
preempt_count 00000101, exited with fffefc05?
Oct 26 22:20:01 n22_uml cron[1167]: (root) CMD (/usr/lib/sa/sa1 60 5)
Oct 26 22:20:01 n22_uml cron[1170]: (root) CMD (test -x /usr/sbin/run-c=
rons && /usr/sbin/run-crons)
Oct 26 22:20:02 n22_uml run-crons[1181]: (root) CMD (/etc/cron.daily/lo=
grotate.cron)
Oct 26 22:20:02 n22_uml run-crons[1185]: (root) CMD (/etc/cron.daily/ma=
kewhatis)
Oct 26 22:20:21 n22_uml run-crons[1484]: (root) CMD (/etc/cron.daily/ml=
ocate)


I can reproduce it by stressing an apache2 running inside of the UML
process (hostname n22_uml) by this loop from the host:

$ for i in $(seq 1 10000); do echo -en "$i\r"; wget --timeout=3D10 --tr=
ies=3D1 --quiet --no-check-certificate -O /dev/null https://n22_uml/pub=
lic/df.php || break; done; echo

=46rom the UML command line I only get this (senseless lines ?) :

 [ ok ]
Kernel panic - not syncing: Segfault with no mm
0842c768:  [<0836bc48>] dump_stack+0x22/0x24
0842c780:  [<0836bcfc>] panic+0x7a/0x181
0842c7a8:  [<080624cc>] segv+0x24c/0x2b0
0842c858:  [<08062583>] segv_handler+0x53/0x90
0842c880:  [<08073b87>] sig_handler_common+0x57/0xe0
0842cb04:  [<08073d35>] sig_handler+0x45/0x60
0842cb14:  [<0807384b>] hard_handler+0x6b/0xb0
0842cb3c:  [<b776540c>] 0xb776540c


EIP: 0000:[<00000000>] CPU: 0 Tainted: G        W    EFLAGS: 00000000
    Tainted: G        W  =20
EAX: 00000000 EBX: 00000000 ECX: 00100100 EDX: 00200200
ESI: 00000000 EDI: 00000000 EBP: 00000000 DS: ffff ES: 0000
0842c71c:  [<0807bb6d>] show_regs+0xed/0x120
0842c738:  [<0806292c>] panic_exit+0x2c/0x50
0842c748:  [<080a14a1>] notifier_call_chain+0x41/0x60
0842c770:  [<080a15e3>] atomic_notifier_call_chain+0x23/0x30
0842c780:  [<0836bd24>] panic+0xa2/0x181
0842c7a8:  [<080624cc>] segv+0x24c/0x2b0
0842c858:  [<08062583>] segv_handler+0x53/0x90
0842c880:  [<08073b87>] sig_handler_common+0x57/0xe0
0842cb04:  [<08073d35>] sig_handler+0x45/0x60
0842cb14:  [<0807384b>] hard_handler+0x6b/0xb0
0842cb3c:  [<b776540c>] 0xb776540c

The php file for completeness:

n22_uml ~ # cat /var/www/localhost/htdocs/public/df.php
<?php
$ds =3D disk_total_space("/home");
echo $ds . " bytes " . '<br />';
?>


--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
