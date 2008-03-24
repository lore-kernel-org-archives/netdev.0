From: Frederik Himpe <fhimpe@telenet.be>
Subject: Re: [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
Date: Mon, 24 Mar 2008 20:36:08 +0000 (UTC)
Message-ID: <pan.2008.03.24.20.36.07@telenet.be>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
	<20080223000310.4630daa8.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
	<3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
	<Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
	<3d8471ca0803020420ka42319bu1b9888217c869d9d@mail.gmail.com>
	<Pine.LNX.4.64.0803021432200.17919@kivilampi-30.cs.helsinki.fi>
	<3d8471ca0803020515m1e4af9d9xd37a8912e58a4504@mail.gmail.com>
	<Pine.LNX.4.64.0803022145210.18020@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031025210.18640@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755102AbYCXUgc@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 03 Mar 2008 15:53:12 +0200, Ilpo J=C3=A4rvinen
wrote:

> [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
>=20
> It makes fackets_out to grow too slowly compared with the real write
> queue.
>=20
> This shouldn't cause those BUG_TRAP(packets <=3D tp->packets_out) to
> trigger but how knows how such inconsistent fackets_out affects here =
and
> there around TCP when everything is nowadays assuming accurate
> fackets_out. So lets see if this silences them all.
>=20
> Reported by Guillaume Chazarain <guichaz@gmail.com>.

Will this patch be applied to 2.6.24 stable? I think I have been hit by=
=20
the same problem recently:

WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Pid: 16959, comm: X Tainted: P        2.6.24.3-desktop-3mnb #1

Call Trace:
 <IRQ>  [<ffffffff8045550c>] tcp_ack+0x180c/0x1d60
 [<ffffffff80494259>] _read_lock_bh+0x9/0x20
 [<ffffffff80458075>] tcp_rcv_state_process+0x3b5/0xd00
 [<ffffffff8045f818>] tcp_v4_do_rcv+0xc8/0x3f0
 [<ffffffff885601b3>] :nf_conntrack_ipv4:ipv4_confirm+0x33/0x60
 [<ffffffff8043c316>] nf_iterate+0x66/0xc0
 [<ffffffff804621b8>] tcp_v4_rcv+0x898/0xaf0
 [<ffffffff80442ec3>] ip_local_deliver_finish+0xc3/0x250
 [<ffffffff80442b64>] ip_rcv_finish+0x114/0x3b0
 [<ffffffff80443365>] ip_rcv+0x205/0x2f0
 [<ffffffff8041c45c>] netif_receive_skb+0x3ac/0x490
 [<ffffffff88184509>] :forcedeth:nv_napi_poll+0xf9/0x850
 [<ffffffff8041eaa8>] net_rx_action+0x128/0x230
 [<ffffffff802412a5>] __do_softirq+0x75/0xe0
 [<ffffffff8020d4fc>] call_softirq+0x1c/0x30
 [<ffffffff8020f6c5>] do_softirq+0x35/0x90
 [<ffffffff80241228>] irq_exit+0x88/0x90
 [<ffffffff8020f910>] do_IRQ+0x80/0x100
 [<ffffffff8020c881>] ret_from_intr+0x0/0xa
 <EOI>=20
WARNING: at net/ipv4/tcp_input.c:2413 tcp_fastretrans_alert()
Pid: 4053, comm: rsyslogd Tainted: P        2.6.24.3-desktop-3mnb #1

Call Trace:
 <IRQ>  [<ffffffff80455a2d>] tcp_ack+0x1d2d/0x1d60
 [<ffffffff80494259>] _read_lock_bh+0x9/0x20
 [<ffffffff80458075>] tcp_rcv_state_process+0x3b5/0xd00
 [<ffffffff8045f818>] tcp_v4_do_rcv+0xc8/0x3f0
 [<ffffffff885601b3>] :nf_conntrack_ipv4:ipv4_confirm+0x33/0x60
 [<ffffffff8043c316>] nf_iterate+0x66/0xc0
 [<ffffffff804621b8>] tcp_v4_rcv+0x898/0xaf0
 [<ffffffff80442ec3>] ip_local_deliver_finish+0xc3/0x250
 [<ffffffff80442b64>] ip_rcv_finish+0x114/0x3b0
 [<ffffffff80443365>] ip_rcv+0x205/0x2f0
 [<ffffffff8041c45c>] netif_receive_skb+0x3ac/0x490
 [<ffffffff88184509>] :forcedeth:nv_napi_poll+0xf9/0x850
 [<ffffffff8041eaa8>] net_rx_action+0x128/0x230
 [<ffffffff802412a5>] __do_softirq+0x75/0xe0
 [<ffffffff8020d4fc>] call_softirq+0x1c/0x30
 [<ffffffff8020f6c5>] do_softirq+0x35/0x90
 [<ffffffff80241228>] irq_exit+0x88/0x90
 [<ffffffff8020f910>] do_IRQ+0x80/0x100
 [<ffffffff8020c881>] ret_from_intr+0x0/0xa
 <EOI>

--=20
=46rederik Himpe
