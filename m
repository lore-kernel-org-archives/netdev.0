From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 10:31:46 +0200
Message-ID: <1285144306.2639.90.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 septembre 2010 =C3=A0 16:14 +0900, Tetsuo Handa a =C3=A9=
crit :
> I established steps to reproduce this warning using clean 2.6.36-rc5 =
=2E
>=20
> [   37.539697] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [   37.541991] [ INFO: possible irq lock inversion dependency detecte=
d ]
> [   37.541991] 2.6.36-rc5 #1
> [   37.541991] ------------------------------------------------------=
---
> [   37.541991] mount/2681 just changed the state of lock:
> [   37.541991]  (clock-AF_INET){++.?..}, at: [<c135e03c>] xs_udp_writ=
e_space+0x1c/0x50
> [   37.541991] but this lock was taken by another, SOFTIRQ-safe lock =
in the past:
> [   37.541991]  (slock-AF_INET){+.-...}
> [   37.541991]=20
> [   37.541991] and interrupts could create inverse lock ordering betw=
een them.
> [   37.541991]=20
> [   37.541991]=20
> [   37.541991] other info that might help us debug this:
> [   37.541991] no locks held by mount/2681.
> [   37.541991]=20
> [   37.541991] the shortest dependencies between 2nd lock and 1st loc=
k:
> [   37.541991]  -> (slock-AF_INET){+.-...} ops: 562 {
> [   37.541991]     HARDIRQ-ON-W at:
> [   37.541991]                                          [<c106a8de>] =
mark_irqflags+0xfe/0x180
> [   37.541991]                                          [<c106b65d>] =
__lock_acquire+0x38d/0x8e0
> [   37.541991]                                          [<c106cbfa>] =
lock_acquire+0x7a/0xa0
> [   37.541991]                                          [<c138be2e>] =
_raw_spin_lock_bh+0x3e/0x80
> [   37.541991]                                          [<c12daf39>] =
lock_sock_fast+0x29/0x90
> [   37.541991]                                          [<c132b1a4>] =
udp_destroy_sock+0x14/0x40
> [   37.541991]                                          [<c12db293>] =
sk_common_release+0xb3/0xc0
> [   37.541991]                                          [<c132bb18>] =
udp_lib_close+0x8/0x10
> [   37.541991]                                          [<c1331a7e>] =
inet_release+0xbe/0x100
> [   37.541991]                                          [<c12d5476>] =
sock_release+0x66/0x80
> [   37.541991]                                          [<c12d61f2>] =
sock_close+0x12/0x30
> [   37.541991]                                          [<c10c637b>] =
__fput+0x1cb/0x240
> [   37.541991]                                          [<c10c6409>] =
fput+0x19/0x20
> [   37.541991]                                          [<c10c4263>] =
filp_close+0x43/0x70
> [   37.541991]                                          [<c103fdcd>] =
close_files+0xad/0x150
> [   37.541991]                                          [<c103fed9>] =
put_files_struct+0x29/0xf0
> [   37.541991]                                          [<c1040030>] =
exit_files+0x40/0x50
> [   37.541991]                                          [<c10406f6>] =
do_exit+0x116/0x2e0
> [   37.541991]                                          [<c1040924>] =
do_group_exit+0x34/0xb0
> [   37.541991]                                          [<c10409af>] =
sys_exit_group+0xf/0x20
> [   37.541991]                                          [<c138c8d1>] =
syscall_call+0x7/0xb
> [   37.541991]     IN-SOFTIRQ-W at:
> [   37.541991]                                          [<c106a8fe>] =
mark_irqflags+0x11e/0x180
> [   37.541991]                                          [<c106b65d>] =
__lock_acquire+0x38d/0x8e0
> [   37.541991]                                          [<c106cbfa>] =
lock_acquire+0x7a/0xa0
> [   37.541991]                                          [<c138bcb9>] =
_raw_spin_lock+0x39/0x70
> [   37.541991]                                          [<c12d98d1>] =
sk_clone+0xb1/0x2c0
> [   37.541991]                                          [<c130fd7a>] =
inet_csk_clone+0x1a/0xb0
> [   37.541991]                                          [<c132535c>] =
tcp_create_openreq_child+0x1c/0x460
> [   37.541991]                                          [<c1322a2f>] =
tcp_v4_syn_recv_sock+0x3f/0x1e0
> [   37.940862]                                          [<c132592c>] =
tcp_check_req+0x18c/0x3b0
> [   37.940862]                                          [<c1322c1d>] =
tcp_v4_hnd_req+0x4d/0x160
> [   37.940862]                                          [<c1322f49>] =
tcp_v4_do_rcv+0x159/0x280
> [   37.940862]                                          [<c13235e4>] =
tcp_v4_rcv+0x574/0xa30
> [   37.940862]                                          [<c1305443>] =
ip_local_deliver_finish+0x103/0x320
> [   37.940862]                                          [<c1305690>] =
ip_local_deliver+0x30/0x40
> [   37.940862]                                          [<c1305809>] =
ip_rcv_finish+0x169/0x480
> [   37.940862]                                          [<c1305cba>] =
ip_rcv+0x19a/0x2b0
> [   37.940862]                                          [<c12e691d>] =
__netif_receive_skb+0x21d/0x310
> [   37.940862]                                          [<c12e7428>] =
process_backlog+0x88/0x160
> [   37.940862]                                          [<c12e77f7>] =
net_rx_action+0x127/0x140
> [   37.940862]                                          [<c1042e70>] =
__do_softirq+0xd0/0x130
> [   37.940862]     INITIAL USE at:
> [   37.940862]                                         [<c106b490>] _=
_lock_acquire+0x1c0/0x8e0
> [   37.940862]                                         [<c106cbfa>] l=
ock_acquire+0x7a/0xa0
> [   37.940862]                                         [<c138be2e>] _=
raw_spin_lock_bh+0x3e/0x80
> [   37.940862]                                         [<c12daf39>] l=
ock_sock_fast+0x29/0x90
> [   37.940862]                                         [<c132b1a4>] u=
dp_destroy_sock+0x14/0x40
> [   37.940862]                                         [<c12db293>] s=
k_common_release+0xb3/0xc0
> [   37.940862]                                         [<c132bb18>] u=
dp_lib_close+0x8/0x10
> [   37.940862]                                         [<c1331a7e>] i=
net_release+0xbe/0x100
> [   37.940862]                                         [<c12d5476>] s=
ock_release+0x66/0x80
> [   37.940862]                                         [<c12d61f2>] s=
ock_close+0x12/0x30
> [   37.940862]                                         [<c10c637b>] _=
_fput+0x1cb/0x240
> [   37.940862]                                         [<c10c6409>] f=
put+0x19/0x20
> [   37.940862]                                         [<c10c4263>] f=
ilp_close+0x43/0x70
> [   37.940862]                                         [<c103fdcd>] c=
lose_files+0xad/0x150
> [   37.940862]                                         [<c103fed9>] p=
ut_files_struct+0x29/0xf0
> [   37.940862]                                         [<c1040030>] e=
xit_files+0x40/0x50
> [   37.940862]                                         [<c10406f6>] d=
o_exit+0x116/0x2e0
> [   37.940862]                                         [<c1040924>] d=
o_group_exit+0x34/0xb0
> [   37.940862]                                         [<c10409af>] s=
ys_exit_group+0xf/0x20
> [   37.940862]                                         [<c138c8d1>] s=
yscall_call+0x7/0xb
> [   37.940862]   }
> [   37.940862]   ... key      at: [<c1d4c9d0>] af_family_slock_keys+0=
x10/0x140
> [   37.940862]   ... acquired at:
> [   37.940862]    [<c106910b>] check_prevs_add+0xab/0x100
> [   37.940862]    [<c1069495>] validate_chain+0x305/0x5a0
> [   37.940862]    [<c106b57d>] __lock_acquire+0x2ad/0x8e0
> [   37.940862]    [<c106cbfa>] lock_acquire+0x7a/0xa0
> [   37.940862]    [<c138c46e>] _raw_write_lock_bh+0x3e/0x80
> [   37.940862]    [<c13100a6>] inet_csk_listen_stop+0x86/0x160
> [   37.940862]    [<c1312c02>] tcp_close+0x382/0x390
> [   37.940862]    [<c1331a7e>] inet_release+0xbe/0x100
> [   37.940862]    [<c12d5476>] sock_release+0x66/0x80
> [   37.940862]    [<c12d61f2>] sock_close+0x12/0x30
> [   37.940862]    [<c10c637b>] __fput+0x1cb/0x240
> [   37.940862]    [<c10c6409>] fput+0x19/0x20
> [   37.940862]    [<c10c4263>] filp_close+0x43/0x70
> [   37.940862]    [<c10c42fd>] sys_close+0x6d/0x110
> [   37.940862]    [<c138c8d1>] syscall_call+0x7/0xb
> [   37.940862]=20
> [   37.940862] -> (clock-AF_INET){++.?..} ops: 72 {
> [   37.940862]    HARDIRQ-ON-W at:
> [   37.940862]                                        [<c106a8de>] ma=
rk_irqflags+0xfe/0x180
> [   37.940862]                                        [<c106b65d>] __=
lock_acquire+0x38d/0x8e0
> [   37.940862]                                        [<c106cbfa>] lo=
ck_acquire+0x7a/0xa0
> [   37.940862]                                        [<c138c46e>] _r=
aw_write_lock_bh+0x3e/0x80
> [   37.940862]                                        [<c12db20f>] sk=
_common_release+0x2f/0xc0
> [   37.940862]                                        [<c132bb18>] ud=
p_lib_close+0x8/0x10
> [   37.940862]                                        [<c1331a7e>] in=
et_release+0xbe/0x100
> [   37.940862]                                        [<c12d5476>] so=
ck_release+0x66/0x80
> [   37.940862]                                        [<c12d61f2>] so=
ck_close+0x12/0x30
> [   37.940862]                                        [<c10c637b>] __=
fput+0x1cb/0x240
> [   37.940862]                                        [<c10c6409>] fp=
ut+0x19/0x20
> [   37.940862]                                        [<c10c4263>] fi=
lp_close+0x43/0x70
> [   37.940862]                                        [<c103fdcd>] cl=
ose_files+0xad/0x150
> [   37.940862]                                        [<c103fed9>] pu=
t_files_struct+0x29/0xf0
> [   37.940862]                                        [<c1040030>] ex=
it_files+0x40/0x50
> [   37.940862]                                        [<c10406f6>] do=
_exit+0x116/0x2e0
> [   37.940862]                                        [<c1040924>] do=
_group_exit+0x34/0xb0
> [   37.940862]                                        [<c10409af>] sy=
s_exit_group+0xf/0x20
> [   37.940862]                                        [<c138c8d1>] sy=
scall_call+0x7/0xb
> [   37.940862]    HARDIRQ-ON-R at:
> [   37.940862]                                        [<c106a84e>] ma=
rk_irqflags+0x6e/0x180
> [   37.940862]                                        [<c106b65d>] __=
lock_acquire+0x38d/0x8e0
> [   37.940862]                                        [<c106cbfa>] lo=
ck_acquire+0x7a/0xa0
> [   37.940862]                                        [<c138bfd9>] _r=
aw_read_lock+0x39/0x70
> [   37.940862]                                        [<c135ddae>] xs=
_tcp_state_change+0x1e/0x1d0
> [   37.940862]                                        [<c131bd38>] tc=
p_rcv_synsent_state_process+0x398/0x590
> [   37.940862]                                        [<c131c3d7>] tc=
p_rcv_state_process+0x4a7/0x560
> [   37.940862]                                        [<c1322e61>] tc=
p_v4_do_rcv+0x71/0x280
> [   37.940862]                                        [<c12da206>] __=
release_sock+0x66/0x150
> [   37.940862]                                        [<c12daf07>] re=
lease_sock+0x87/0x90
> [   37.940862]                                        [<c1331e6a>] in=
et_stream_connect+0x5a/0x1b0
> [   37.940862]                                        [<c12d7d68>] ke=
rnel_connect+0x18/0x30
> [   37.940862]                                        [<c135ea5e>] xs=
_tcp_finish_connecting+0x4e/0x120
> [   37.940862]                                        [<c135eb8b>] xs=
_tcp_setup_socket+0x5b/0x180
> [   37.940862]                                        [<c135edc4>] xs=
_tcp_connect_worker4+0x14/0x20
> [   37.940862]                                        [<c1051547>] pr=
ocess_one_work+0x147/0x3a0
> [   37.940862]                                        [<c1051886>] wo=
rker_thread+0xa6/0x200
> [   37.940862]                                        [<c1056765>] kt=
hread+0x75/0x80
> [   37.940862]                                        [<c10031fa>] ke=
rnel_thread_helper+0x6/0x1c
> [   37.940862]    IN-SOFTIRQ-R at:
> [   37.940862]                                        [<c106a8fe>] ma=
rk_irqflags+0x11e/0x180
> [   37.940862]                                        [<c106b65d>] __=
lock_acquire+0x38d/0x8e0
> [   37.940862]                                        [<c106cbfa>] lo=
ck_acquire+0x7a/0xa0
> [   37.940862]                                        [<c138bfd9>] _r=
aw_read_lock+0x39/0x70
> [   37.940862]                                        [<c135dc81>] xs=
_tcp_data_ready+0x21/0x90
> [   37.940862]                                        [<c131a1f8>] tc=
p_data_queue+0x248/0x820
> [   37.940862]                                        [<c131b56e>] tc=
p_rcv_established+0xae/0x4e0
> [   37.940862]                                        [<c1322fc1>] tc=
p_v4_do_rcv+0x1d1/0x280
> [   37.940862]                                        [<c13235e4>] tc=
p_v4_rcv+0x574/0xa30
> [   37.940862]                                        [<c1305443>] ip=
_local_deliver_finish+0x103/0x320
> [   37.940862]                                        [<c1305690>] ip=
_local_deliver+0x30/0x40
> [   37.940862]                                        [<c1305809>] ip=
_rcv_finish+0x169/0x480
> [   37.940862]                                        [<c1305cba>] ip=
_rcv+0x19a/0x2b0
> [   37.940862]                                        [<c12e691d>] __=
netif_receive_skb+0x21d/0x310
> [   37.940862]                                        [<c12e7428>] pr=
ocess_backlog+0x88/0x160
> [   37.940862]                                        [<c12e77f7>] ne=
t_rx_action+0x127/0x140
> [   37.940862]                                        [<c1042e70>] __=
do_softirq+0xd0/0x130
> [   37.940862]    SOFTIRQ-ON-R at:
> [   37.940862]                                        [<c106a8c2>] ma=
rk_irqflags+0xe2/0x180
> [   37.940862]                                        [<c106b65d>] __=
lock_acquire+0x38d/0x8e0
> [   37.940862]                                        [<c106cbfa>] lo=
ck_acquire+0x7a/0xa0
> [   37.940862]                                        [<c138bfd9>] _r=
aw_read_lock+0x39/0x70
> [   37.940862]                                        [<c135e03c>] xs=
_udp_write_space+0x1c/0x50
> [   37.940862]                                        [<c135e14a>] xs=
_udp_do_set_buffer_size+0x8a/0x90
> [   37.940862]                                        [<c135e18d>] xs=
_udp_set_buffer_size+0x3d/0x40
> [   37.940862]                                        [<c13594d8>] rp=
c_setbufsize+0x28/0x30
> [   37.940862]                                        [<e0967314>] nf=
s_server_set_fsinfo+0x364/0x400 [nfs]
> [   37.940862]                                        [<e0967415>] nf=
s_probe_fsinfo+0x65/0x100 [nfs]
> [   37.940862]                                        [<e0967717>] nf=
s_create_server+0x87/0x240 [nfs]
> [   37.940862]                                        [<e0971aeb>] nf=
s_get_sb+0x8b/0x240 [nfs]
> [   37.940862]                                        [<c10c7f41>] vf=
s_kern_mount+0x71/0x190
> [   37.940862]                                        [<c10c8287>] do=
_kern_mount+0x37/0x90
> [   37.940862]                                        [<c10de6c7>] do=
_new_mount+0x57/0xa0
> [   37.940862]                                        [<c10decc1>] do=
_mount+0x171/0x1b0
> [   37.940862]                                        [<c10defbc>] sy=
s_mount+0x6c/0xa0
> [   37.940862]                                        [<c138c8d1>] sy=
scall_call+0x7/0xb
> [   37.940862]    INITIAL USE at:
> [   37.940862]                                       [<c106b490>] __l=
ock_acquire+0x1c0/0x8e0
> [   37.940862]                                       [<c106cbfa>] loc=
k_acquire+0x7a/0xa0
> [   37.940862]                                       [<c138c46e>] _ra=
w_write_lock_bh+0x3e/0x80
> [   37.940862]                                       [<c12db20f>] sk_=
common_release+0x2f/0xc0
> [   37.940862]                                       [<c132bb18>] udp=
_lib_close+0x8/0x10
> [   37.940862]                                       [<c1331a7e>] ine=
t_release+0xbe/0x100
> [   37.940862]                                       [<c12d5476>] soc=
k_release+0x66/0x80
> [   37.940862]                                       [<c12d61f2>] soc=
k_close+0x12/0x30
> [   37.940862]                                       [<c10c637b>] __f=
put+0x1cb/0x240
> [   37.940862]                                       [<c10c6409>] fpu=
t+0x19/0x20
> [   37.940862]                                       [<c10c4263>] fil=
p_close+0x43/0x70
> [   37.940862]                                       [<c103fdcd>] clo=
se_files+0xad/0x150
> [   37.940862]                                       [<c103fed9>] put=
_files_struct+0x29/0xf0
> [   37.940862]                                       [<c1040030>] exi=
t_files+0x40/0x50
> [   37.940862]                                       [<c10406f6>] do_=
exit+0x116/0x2e0
> [   37.940862]                                       [<c1040924>] do_=
group_exit+0x34/0xb0
> [   37.940862]                                       [<c10409af>] sys=
_exit_group+0xf/0x20
> [   37.940862]                                       [<c138c8d1>] sys=
call_call+0x7/0xb
> [   37.940862]  }
> [   37.940862]  ... key      at: [<c1d4cb10>] af_callback_keys+0x10/0=
x130
> [   37.940862]  ... acquired at:
> [   37.940862]    [<c1069d46>] check_usage_backwards+0x76/0xd0
> [   37.940862]    [<c1069f59>] mark_lock_irq+0x99/0x240
> [   37.940862]    [<c106abfc>] mark_lock+0x21c/0x3c0
> [   37.940862]    [<c106a8c2>] mark_irqflags+0xe2/0x180
> [   37.940862]    [<c106b65d>] __lock_acquire+0x38d/0x8e0
> [   37.940862]    [<c106cbfa>] lock_acquire+0x7a/0xa0
> [   37.940862]    [<c138bfd9>] _raw_read_lock+0x39/0x70
> [   37.940862]    [<c135e03c>] xs_udp_write_space+0x1c/0x50
> [   37.940862]    [<c135e14a>] xs_udp_do_set_buffer_size+0x8a/0x90
> [   37.940862]    [<c135e18d>] xs_udp_set_buffer_size+0x3d/0x40
> [   37.940862]    [<c13594d8>] rpc_setbufsize+0x28/0x30
> [   37.940862]    [<e0967314>] nfs_server_set_fsinfo+0x364/0x400 [nfs=
]
> [   37.940862]    [<e0967415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
> [   37.940862]    [<e0967717>] nfs_create_server+0x87/0x240 [nfs]
> [   37.940862]    [<e0971aeb>] nfs_get_sb+0x8b/0x240 [nfs]
> [   37.940862]    [<c10c7f41>] vfs_kern_mount+0x71/0x190
> [   37.940862]    [<c10c8287>] do_kern_mount+0x37/0x90
> [   37.940862]    [<c10de6c7>] do_new_mount+0x57/0xa0
> [   37.940862]    [<c10decc1>] do_mount+0x171/0x1b0
> [   37.940862]    [<c10defbc>] sys_mount+0x6c/0xa0
> [   37.940862]    [<c138c8d1>] syscall_call+0x7/0xb
> [   37.940862]=20
> [   37.940862]=20
> [   37.940862] stack backtrace:
> [   37.940862] Pid: 2681, comm: mount Not tainted 2.6.36-rc5 #1
> [   37.940862] Call Trace:
> [   37.940862]  [<c103deb8>] ? printk+0x18/0x20
> [   37.940862]  [<c1069bd8>] print_irq_inversion_bug+0x108/0x120
> [   37.940862]  [<c1069d46>] check_usage_backwards+0x76/0xd0
> [   37.940862]  [<c1069f59>] mark_lock_irq+0x99/0x240
> [   37.940862]  [<c1069cd0>] ? check_usage_backwards+0x0/0xd0
> [   37.940862]  [<c106abfc>] mark_lock+0x21c/0x3c0
> [   37.940862]  [<c106a8c2>] mark_irqflags+0xe2/0x180
> [   37.940862]  [<c106b65d>] __lock_acquire+0x38d/0x8e0
> [   37.940862]  [<c109a5fe>] ? mempool_free_slab+0xe/0x10
> [   37.940862]  [<c109a5d8>] ? mempool_free+0x98/0xa0
> [   37.940862]  [<c106cbfa>] lock_acquire+0x7a/0xa0
> [   37.940862]  [<c135e03c>] ? xs_udp_write_space+0x1c/0x50
> [   37.940862]  [<c138bfd9>] _raw_read_lock+0x39/0x70
> [   37.940862]  [<c135e03c>] ? xs_udp_write_space+0x1c/0x50
> [   37.940862]  [<c135e03c>] xs_udp_write_space+0x1c/0x50
> [   37.940862]  [<c135e14a>] xs_udp_do_set_buffer_size+0x8a/0x90
> [   37.940862]  [<c135e18d>] xs_udp_set_buffer_size+0x3d/0x40
> [   37.940862]  [<c135e150>] ? xs_udp_set_buffer_size+0x0/0x40
> [   37.940862]  [<c13594d8>] rpc_setbufsize+0x28/0x30
> [   37.940862]  [<e0967314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
> [   37.940862]  [<e0967415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
> [   37.940862]  [<c10bf558>] ? cache_alloc_debugcheck_after+0x98/0x1d=
0
> [   37.940862]  [<e096e1d3>] ? nfs_alloc_fattr+0x23/0x30 [nfs]
> [   37.940862]  [<e0967717>] nfs_create_server+0x87/0x240 [nfs]
> [   37.940862]  [<e096e1f5>] ? nfs_alloc_fhandle+0x15/0x30 [nfs]
> [   37.940862]  [<e0971aeb>] nfs_get_sb+0x8b/0x240 [nfs]
> [   37.940862]  [<e09719b0>] ? nfs_compare_super+0x0/0x90 [nfs]
> [   37.940862]  [<c10c7f41>] vfs_kern_mount+0x71/0x190
> [   37.940862]  [<c10dc11c>] ? get_fs_type+0x8c/0xa0
> [   37.940862]  [<c10c8287>] do_kern_mount+0x37/0x90
> [   37.940862]  [<c10de6c7>] do_new_mount+0x57/0xa0
> [   37.940862]  [<c10decc1>] do_mount+0x171/0x1b0
> [   37.940862]  [<c10defbc>] sys_mount+0x6c/0xa0
> [   37.940862]  [<c138c8d1>] syscall_call+0x7/0xb
>=20
> Boot and login and run test.sh below
>=20
> --- test.sh start ---
> #! /bin/sh
> ./a.out
> echo 1 > /proc/sys/kernel/printk_delay
> mount 127.0.0.1:/usr/src/ /mnt/
> umount /mnt/
> --- test.sh end ---
>=20
> where a.out is made by "gcc -Wall -O3 test.c"
>=20
> --- test.c start ---
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <arpa/inet.h>
>=20
> int main(int argc, char *argv[])
> {
> 	int fd1 =3D socket(AF_INET, SOCK_STREAM, 0);
> 	int fd2 =3D socket(AF_INET, SOCK_STREAM, 0);
> 	struct sockaddr_in addr =3D { };
> 	socklen_t size =3D sizeof(addr);
> 	addr.sin_family =3D AF_INET;
> 	addr.sin_addr.s_addr =3D htonl(INADDR_LOOPBACK);
> 	addr.sin_port =3D htons(0);
> 	bind(fd1, (struct sockaddr *) &addr, sizeof(addr));
> 	listen(fd1, 5);
> 	getsockname(fd1, (struct sockaddr *) &addr, &size);
> 	connect(fd2, (struct sockaddr *) &addr, sizeof(addr));
> 	close(fd1);
> 	close(fd2);
> 	return 0;
> }
> --- test.c end ---
>=20
> Config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.36-rc5
> Full log is at http://I-love.SAKURA.ne.jp/tmp/dmesg-2.6.36-rc5.txt
>=20
> I'm using Debian Sarge on i686.
>=20
> Regards.

Thanks

no splat here using your script/program

And I dont really understand why a mixed udp & tcp workload could
trigger a lockdep splat.

Ah, all sockets of a same family (AF_INET in your case) share a single
af_callback_keys :
commit da21f24dd7395 said so.

Problem is about sk_callback_lock, not the lock_sock_fast()=20

I wonder if we dont need to use a separate "struct lock_class_key" per
protocol (stored in struct proto) ...

Could you try following interim patch ?

Thanks

diff --git a/include/net/sock.h b/include/net/sock.h
index adab9dc..c5104bc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -800,6 +800,7 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
+	struct lock_class_key *callback_key;
 };
=20
 extern int proto_register(struct proto *prot, int alloc_slab);
diff --git a/net/core/sock.c b/net/core/sock.c
index b05b9b6..afd0f69 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1210,7 +1210,9 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 		spin_lock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
-				af_callback_keys + newsk->sk_family,
+				sk->sk_prot->callback_key ?
+					sk->sk_prot->callback_key :
+					af_callback_keys + newsk->sk_family,
 				af_family_clock_key_strings[newsk->sk_family]);
=20
 		newsk->sk_dst_cache	=3D NULL;
@@ -1965,6 +1967,9 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
 	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
+			sk->sk_prot->callback_key ?
+				sk->sk_prot->callback_key :
+				af_callback_keys + newsk->sk_family,
 			af_callback_keys + sk->sk_family,
 			af_family_clock_key_strings[sk->sk_family]);
=20
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fb23c2e..c0877b6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1870,6 +1870,8 @@ unsigned int udp_poll(struct file *file, struct s=
ocket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(udp_poll);
=20
+static struct lock_class_key udp_callback_key;
+
 struct proto udp_prot =3D {
 	.name		   =3D "UDP",
 	.owner		   =3D THIS_MODULE,
@@ -1899,6 +1901,7 @@ struct proto udp_prot =3D {
 	.compat_setsockopt =3D compat_udp_setsockopt,
 	.compat_getsockopt =3D compat_udp_getsockopt,
 #endif
+	.callback_key	   =3D &udp_callback_key,
 };
 EXPORT_SYMBOL(udp_prot);
=20
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index ab76aa9..51b159d 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -32,6 +32,8 @@ static const struct net_protocol udplite_protocol =3D=
 {
 	.netns_ok	=3D 1,
 };
=20
+static struct lock_class_key udplite_callback_key;
+
 struct proto 	udplite_prot =3D {
 	.name		   =3D "UDP-Lite",
 	.owner		   =3D THIS_MODULE,
@@ -57,6 +59,7 @@ struct proto 	udplite_prot =3D {
 	.compat_setsockopt =3D compat_udp_setsockopt,
 	.compat_getsockopt =3D compat_udp_getsockopt,
 #endif
+	.callback_key	   =3D &udplite_callback_key,
 };
 EXPORT_SYMBOL(udplite_prot);
=20
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5acb356..0777934 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1441,6 +1441,8 @@ void udp6_proc_exit(struct net *net) {
=20
 /* -------------------------------------------------------------------=
----- */
=20
+static struct lock_class_key udp6_callback_key;
+
 struct proto udpv6_prot =3D {
 	.name		   =3D "UDPv6",
 	.owner		   =3D THIS_MODULE,
@@ -1469,6 +1471,7 @@ struct proto udpv6_prot =3D {
 	.compat_setsockopt =3D compat_udpv6_setsockopt,
 	.compat_getsockopt =3D compat_udpv6_getsockopt,
 #endif
+	.callback_key	   =3D &udp6_callback_key,
 };
=20
 static struct inet_protosw udpv6_protosw =3D {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 5f48fad..7bbb627 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -31,6 +31,8 @@ static const struct inet6_protocol udplitev6_protocol=
 =3D {
 	.flags		=3D	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
=20
+static struct lock_class_key udp6lite_callback_key;
+
 struct proto udplitev6_prot =3D {
 	.name		   =3D "UDPLITEv6",
 	.owner		   =3D THIS_MODULE,
@@ -55,6 +57,7 @@ struct proto udplitev6_prot =3D {
 	.compat_setsockopt =3D compat_udpv6_setsockopt,
 	.compat_getsockopt =3D compat_udpv6_getsockopt,
 #endif
+	.callback_key	   =3D &udp6lite_callback_key,
 };
=20
 static struct inet_protosw udplite6_protosw =3D {


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
