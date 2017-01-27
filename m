From: Sachin Sant <sachinp@linux.vnet.ibm.com>
Subject: [next-20170124] Kernel oops(rt6_fill_node) during reboot of LPAR
Date: Fri, 27 Jan 2017 18:24:53 +0530
Message-ID: <9520531C-6458-4442-9ED5-3598E72C7C6A@linux.vnet.ibm.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Michael Ellerman <michael@ellerman.id.au>,
 Stephen Rothwell <sfr@canb.auug.org.au>, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
 netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

While rebooting PowerVM LPAR running 4.10.0-rc5-next-20170124
on a POWER8 box, following kernel oops is displayed.

This problem was introduced with next-20170123. next-20170120 works.
Initial analysis points to following patch included with next-20170123

commit a1a22c12060e4b9c52f45d4b3460f614e00162a2
net: ipv6: Keep nexthop of multipath route on admin down


[  OK  ] Stopped Logout off all iSCSI sessions on shutdown.
[  OK  ] Stopped CUPS Printing Service.
[  OK  ] Stopped Dynamic System Tuning Daemon.
[  OK  ] Stopped target Network.
         Stopping LSB: Bring up/down networking...
[   86.292027] Unable to handle kernel paging request for data at =
address 0x000001d4
[   86.292050] Faulting instruction address: 0xc0000000008734b0
[   86.292054] Oops: Kernel access of bad area, sig: 11 [#1]
[   86.292056] SMP NR_CPUS=3D2048=20
[   86.292057] NUMA=20
[   86.292059] pSeries
[   86.292062] Modules linked in: xt_CHECKSUM ipt_MASQUERADE =
nf_nat_masquerade_ipv4 tun kvm_pr kvm ip6t_rpfilter ipt_REJECT =
nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink =
ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 =
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security =
ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 =
nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw =
ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter =
rpcrdma ib_isert iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi =
ib_srpt target_core_mod ib_srp ib_ipoib rdma_ucm ib_ucm ib_uverbs =
ib_umad rdma_cm ib_cm iw_cm iw_cxgb3 ib_core ghash_generic xts gf128mul =
tpm_ibmvtpm tpm vmx_crypto sg pseries_rng nfsd auth_rpcgss nfs_acl lockd
[   86.292099]  grace sunrpc ip_tables xfs libcrc32c sr_mod sd_mod cdrom =
cxgb3 ibmvscsi ibmveth scsi_transport_srp mdio dm_mirror dm_region_hash =
dm_log dm_mod
[   86.292109] CPU: 0 PID: 1500 Comm: NetworkManager Not tainted =
4.10.0-rc5-next-20170124 #1
[   86.292113] task: c00000000319b800 task.stack: c0000000fb9e0000
[   86.292115] NIP: c0000000008734b0 LR: c000000000873444 CTR: =
c000000000879490
[   86.292118] REGS: c0000000fb9e33d0 TRAP: 0300   Not tainted  =
(4.10.0-rc5-next-20170124)
[   86.292121] MSR: 8000000000009033 <SF,EE,ME,IR,DR,RI,LE>
[   86.292124]   CR: 28004428  XER: 00000000
[   86.292128] CFAR: c000000000008850 DAR: 00000000000001d4 DSISR: =
40000000 SOFTE: 1=20
[   86.292128] GPR00: c000000000873444 c0000000fb9e3650 c000000000ff9f00 =
0000000000000000=20
[   86.292128] GPR04: c0000000fb9e36b4 0000000000000004 c00000026ff50024 =
0000000000007e80=20
[   86.292128] GPR08: 0000000000000000 0000000000000000 0000000000000002 =
0000000000000014=20
[   86.292128] GPR12: c000000000879490 c00000000e800000 0000000000000000 =
0000000000000000=20
[   86.292128] GPR16: 0000000000000000 0000000000000000 0000000000000000 =
c000000000fa6d00=20
[   86.292128] GPR20: 0000000000000000 c000000000fa6d00 0000000000000000 =
c00000026a5bba00=20
[   86.292128] GPR24: c000000000fa6d00 0000000000000000 0000000000000000 =
00000000384005dc=20
[   86.292128] GPR28: 0000000000000000 c00000026a5bba00 c000000279f71c00 =
c00000026ff50000=20
[   86.292163] NIP [c0000000008734b0] rt6_fill_node.isra.42+0x150/0x640
[   86.292166] LR [c000000000873444] rt6_fill_node.isra.42+0xe4/0x640
[   86.292169] Call Trace:
[   86.292171] [c0000000fb9e3650] [c000000000873444] =
rt6_fill_node.isra.42+0xe4/0x640 (unreliable)
[   86.292175] [c0000000fb9e3710] [c000000000878718] =
rt6_dump_route+0x68/0xa0
[   86.292178] [c0000000fb9e3780] [c0000000008794d8] =
fib6_dump_node+0x48/0xb0
[   86.292182] [c0000000fb9e37b0] [c000000000878de8] =
fib6_walk_continue+0x1d8/0x200
[   86.292185] [c0000000fb9e3800] [c000000000879134] fib6_walk+0x44/0xa0
[   86.292189] [c0000000fb9e3840] [c00000000087a0f4] =
inet6_dump_fib+0x1f4/0x2d0
[   86.292193] [c0000000fb9e38f0] [c0000000007ae9cc] =
netlink_dump+0x14c/0x370
[   86.292196] [c0000000fb9e3940] [c0000000007af428] =
__netlink_dump_start+0x198/0x210
[   86.292201] [c0000000fb9e3990] [c0000000007833f4] =
rtnetlink_rcv_msg+0x194/0x300
[   86.292204] [c0000000fb9e3a10] [c0000000007b1e48] =
netlink_rcv_skb+0x128/0x140
[   86.292208] [c0000000fb9e3a50] [c00000000077f46c] =
rtnetlink_rcv+0x3c/0x60
[   86.292211] [c0000000fb9e3a80] [c0000000007b13dc] =
netlink_unicast+0x1ec/0x370
[   86.292215] [c0000000fb9e3ae0] [c0000000007b1adc] =
netlink_sendmsg+0x40c/0x480
[   86.292219] [c0000000fb9e3b70] [c00000000073caec] =
sock_sendmsg+0x5c/0x90
[   86.292223] [c0000000fb9e3ba0] [c00000000073d79c] =
___sys_sendmsg+0x31c/0x330
[   86.292226] [c0000000fb9e3d30] [c00000000073ece4] =
__sys_sendmsg+0x54/0xc0
[   86.292229] [c0000000fb9e3dd0] [c00000000073f88c] =
SyS_socketcall+0x35c/0x3e0
[   86.292234] [c0000000fb9e3e30] [c00000000000b184] =
system_call+0x38/0xe0
[   86.292236] Instruction dump:
[   86.292238] 39200000 913f0018 e93e0018 e9490048 794807e1 41820010 =
e9290048 792af7e3=20
[   86.292243] 41820024 39200010 913f0018 e93e0158 <812901d4> 2f890000 =
419e000c 39200011=20
[   86.292249] ---[ end trace 6bc185aea0ad63a6 ]---
[   86.292251]=20
[   88.292296] Kernel panic - not syncing: Fatal exception in interrupt
[   88.292399] Rebooting in 10 seconds..
