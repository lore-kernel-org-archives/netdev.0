From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue timed out" when
 skb has huge linear buffer
Date: Fri, 31 Jan 2014 14:29:02 +0100
Message-ID: <52EBA51E.808@citrix.com>
References: <52EAA31B.1090606@schaman.hu> <1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Michael Chan <mchan@broadcom.com>,
	Zoltan Kiss <zoltan.kiss@schaman.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/01/14 21:34, Michael Chan wrote:
> On Thu, 2014-01-30 at 19:08 +0000, Zoltan Kiss wrote:
>> I've experienced some queue timeout problems mentioned in the subject
>> with igb and bnx2 cards.
> Please provide the full tx timeout dmesg.  bnx2 dumps some diagnostic
> information during tx timeout that may be useful.  Thanks.
Hi,

Here is some:

[ 5417.275463] ------------[ cut here ]------------
[ 5417.275472] WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0x156/0x1f0()
[ 5417.275474] NETDEV WATCHDOG: eth1 (bnx2): transmit queue 2 timed out
[ 5417.275476] Modules linked in: tun nfsv3 nfs_acl rpcsec_gss_krb5 
auth_rpcgss oid_registry nfsv4 nfs fscache lockd sunrpc ipv6 
openvswitch(O) ipt_REJECT nf_conntrack_ipv
rack xt_tcpudp iptable_filter ip_tables x_tables nls_utf8 isofs 
dm_multipath scsi_dh dm_mod dcdbas coretemp microcode psmouse serio_raw 
lpc_ich mfd_core hid_generic ehci_p
sg hed bnx2 usbhid hid sr_mod cdrom sd_mod pata_acpi ata_generic 
ata_piix libata uhci_hcd mptsas mptscsih mptbase scsi_transport_sas scsi_mod
[ 5417.275517] CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G O 
3.10.11-0.xs1.8.50.170.377582 #1
[ 5417.275518] Hardware name: Dell Inc. PowerEdge R710/00W9X3, BIOS 
1.2.6 07/17/2009
[ 5417.275520]  000000ff f008be08 c1488c53 f008be30 c1046664 c1658a88 
f008be5c 000000ff
[ 5417.275525]  c13fc146 c13fc146 ee96a000 00000002 00137d44 f008be48 
c1046723 00000009
[ 5417.275530]  f008be40 c1658a88 f008be5c f008be80 c13fc146 c16556e1 
000000ff c1658a88
[ 5417.275535] Call Trace:
[ 5417.275539]  [<c1488c53>] dump_stack+0x16/0x1b
[ 5417.275544]  [<c1046664>] warn_slowpath_common+0x64/0x80
[ 5417.275546]  [<c13fc146>] ? dev_watchdog+0x156/0x1f0
[ 5417.275549]  [<c13fc146>] ? dev_watchdog+0x156/0x1f0
[ 5417.275551]  [<c1046723>] warn_slowpath_fmt+0x33/0x40
[ 5417.275554]  [<c13fc146>] dev_watchdog+0x156/0x1f0
[ 5417.275559]  [<c10549ce>] call_timer_fn+0x3e/0xf0
[ 5417.275563]  [<c107293e>] ? finish_task_switch+0x4e/0xb0
[ 5417.275565]  [<c13fbff0>] ? __netdev_watchdog_up+0x60/0x60
[ 5417.275568]  [<c1055c1b>] run_timer_softirq+0x1ab/0x210
[ 5417.275571]  [<c13fbff0>] ? __netdev_watchdog_up+0x60/0x60
[ 5417.275574]  [<c104e3f4>] __do_softirq+0xc4/0x200
[ 5417.275577]  [<c1493547>] ? xen_do_upcall+0x7/0xc
[ 5417.275579]  [<c104e550>] run_ksoftirqd+0x20/0x50
[ 5417.275582]  [<c106f182>] smpboot_thread_fn+0x142/0x150
[ 5417.275586]  [<c1067a2b>] kthread+0x9b/0xa0
[ 5417.275589]  [<c106f040>] ? smpboot_create_threads+0x60/0x60
[ 5417.275591]  [<c1070000>] ? cpu_rt_runtime_read+0x40/0x80
[ 5417.275594]  [<c1492f77>] ret_from_kernel_thread+0x1b/0x28
[ 5417.275596]  [<c1067990>] ? kthread_freezable_should_stop+0x60/0x60
[ 5417.275599] ---[ end trace 691f572d388226ca ]---
[ 5417.275602] bnx2 0000:01:00.1 eth1: <--- start FTQ dump --->
[ 5417.275622] bnx2 0000:01:00.1 eth1: RV2P_PFTQ_CTL 00010000
[ 5417.275629] bnx2 0000:01:00.1 eth1: RV2P_TFTQ_CTL 00020000
[ 5417.275636] bnx2 0000:01:00.1 eth1: RV2P_MFTQ_CTL 00004000
[ 5417.275643] bnx2 0000:01:00.1 eth1: TBDR_FTQ_CTL 00004002
[ 5417.275650] bnx2 0000:01:00.1 eth1: TDMA_FTQ_CTL 00010002
[ 5417.275657] bnx2 0000:01:00.1 eth1: TXP_FTQ_CTL 00010000
[ 5417.275663] bnx2 0000:01:00.1 eth1: TXP_FTQ_CTL 00010000
[ 5417.275670] bnx2 0000:01:00.1 eth1: TPAT_FTQ_CTL 00010000
[ 5417.275677] bnx2 0000:01:00.1 eth1: RXP_CFTQ_CTL 00008000
[ 5417.275684] bnx2 0000:01:00.1 eth1: RXP_FTQ_CTL 00100000
[ 5417.275690] bnx2 0000:01:00.1 eth1: COM_COMXQ_FTQ_CTL 00010000
[ 5417.275698] bnx2 0000:01:00.1 eth1: COM_COMTQ_FTQ_CTL 00020000
[ 5417.275705] bnx2 0000:01:00.1 eth1: COM_COMQ_FTQ_CTL 00010000
[ 5417.275712] bnx2 0000:01:00.1 eth1: CP_CPQ_FTQ_CTL 00004000
[ 5417.275718] bnx2 0000:01:00.1 eth1: CPU states:
[ 5417.275730] bnx2 0000:01:00.1 eth1: 045000 mode b84c state 80001000 
evt_mask 500 pc 8001284 pc 8001284 instr 1440fffc
[ 5417.275746] bnx2 0000:01:00.1 eth1: 085000 mode b84c state 80005000 
evt_mask 500 pc 8000a54 pc 8000a5c instr 10400016
[ 5417.275785] bnx2 0000:01:00.1 eth1: 0c5000 mode b84c state 80001000 
evt_mask 500 pc 8004c20 pc 8004c20 instr 32050003
[ 5417.275801] bnx2 0000:01:00.1 eth1: 105000 mode b8cc state 80000000 
evt_mask 500 pc 8000a8c pc 8000a94 instr 8c420020
[ 5417.275817] bnx2 0000:01:00.1 eth1: 145000 mode b880 state 80000000 
evt_mask 500 pc 8000ab0 pc 800d1e8 instr 27bd0020
[ 5417.275834] bnx2 0000:01:00.1 eth1: 185000 mode b8cc state 80000000 
evt_mask 500 pc 8000cb0 pc 8000930 instr 8ce800e8
[ 5417.275845] bnx2 0000:01:00.1 eth1: <--- end FTQ dump --->
[ 5417.275851] bnx2 0000:01:00.1 eth1: <--- start TBDC dump --->
[ 5417.275858] bnx2 0000:01:00.1 eth1: TBDC free cnt: 32
[ 5417.275864] bnx2 0000:01:00.1 eth1: LINE     CID  BIDX   CMD VALIDS
[ 5417.275875] bnx2 0000:01:00.1 eth1: 00    001080  17c8   00 [0]
[ 5417.275886] bnx2 0000:01:00.1 eth1: 01    001080  17e0   00 [0]
[ 5417.275897] bnx2 0000:01:00.1 eth1: 02    001080  17e8   00 [0]
[ 5417.275907] bnx2 0000:01:00.1 eth1: 03    001080  17f8   00 [0]
[ 5417.275918] bnx2 0000:01:00.1 eth1: 04    001080  1800   00 [0]
[ 5417.275929] bnx2 0000:01:00.1 eth1: 05    001080  17d0   00 [0]
[ 5417.275940] bnx2 0000:01:00.1 eth1: 06    001080  17d8   00 [0]
[ 5417.275951] bnx2 0000:01:00.1 eth1: 07    001080  17f0   00 [0]
[ 5417.275961] bnx2 0000:01:00.1 eth1: 08    001080  1620   00 [0]
[ 5417.275972] bnx2 0000:01:00.1 eth1: 09    17de00  fbf8   78 [0]
[ 5417.275983] bnx2 0000:01:00.1 eth1: 0a    1bbf80  fef8   9f [0]
[ 5417.275994] bnx2 0000:01:00.1 eth1: 0b    1d2d80  f7f8   7f [0]
[ 5417.276005] bnx2 0000:01:00.1 eth1: 0c    148f00  f7b8   88 [0]
[ 5417.276016] bnx2 0000:01:00.1 eth1: 0d    16af80  f7d0   75 [0]
[ 5417.276026] bnx2 0000:01:00.1 eth1: 0e    1adf80  bfb0   26 [0]
[ 5417.276037] bnx2 0000:01:00.1 eth1: 0f    1ebf80  dd68   3c [0]
[ 5417.276048] bnx2 0000:01:00.1 eth1: 10    1cf700  d1f0   fc [0]
[ 5417.276059] bnx2 0000:01:00.1 eth1: 11    1cdc00  fbf0   7d [0]
[ 5417.276069] bnx2 0000:01:00.1 eth1: 12    15c900  f7f8   ef [0]
[ 5417.276081] bnx2 0000:01:00.1 eth1: 13    17cf00  d7d8   3f [0]
[ 5417.276093] bnx2 0000:01:00.1 eth1: 14    1ecf80  ffb0   b7 [0]
[ 5417.276107] bnx2 0000:01:00.1 eth1: 15    1cbd80  f3e8   bf [0]
[ 5417.276119] bnx2 0000:01:00.1 eth1: 16    179b80  d7f8   d7 [0]
[ 5417.276130] bnx2 0000:01:00.1 eth1: 17    1fdf00  f3e8   7e [0]
[ 5417.276141] bnx2 0000:01:00.1 eth1: 18    1f9780  b578   af [0]
[ 5417.276152] bnx2 0000:01:00.1 eth1: 19    1d7d80  fef0   ff [0]
[ 5417.276163] bnx2 0000:01:00.1 eth1: 1a    1d9e80  5fe8   d7 [0]
[ 5417.276174] bnx2 0000:01:00.1 eth1: 1b    1fff80  ebf8   f8 [0]
[ 5417.276186] bnx2 0000:01:00.1 eth1: 1c    1fbd80  f7d8   7f [0]
[ 5417.276200] bnx2 0000:01:00.1 eth1: 1d    16da80  2ef8   ff [0]
[ 5417.276211] bnx2 0000:01:00.1 eth1: 1e    1f9b80  bf50   8e [0]
[ 5417.276224] bnx2 0000:01:00.1 eth1: 1f    1bdf00  faf8   75 [0]
[ 5417.276231] bnx2 0000:01:00.1 eth1: <--- end TBDC dump --->
[ 5417.276246] bnx2 0000:01:00.1 eth1: DEBUG: intr_sem[0] PCI_CMD[00100406]
[ 5417.276258] bnx2 0000:01:00.1 eth1: DEBUG: PCI_PM[19002008] 
PCI_MISC_CFG[92000088]
[ 5417.276269] bnx2 0000:01:00.1 eth1: DEBUG: EMAC_TX_STATUS[00000008] 
EMAC_RX_STATUS[00000000]
[ 5417.276280] bnx2 0000:01:00.1 eth1: DEBUG: RPM_MGMT_PKT_CTRL[40000088]
[ 5417.276288] bnx2 0000:01:00.1 eth1: DEBUG: 
HC_STATS_INTERRUPT_STATUS[01fb0004]
[ 5417.276298] bnx2 0000:01:00.1 eth1: DEBUG: PBA[00000000]
[ 5417.276304] bnx2 0000:01:00.1 eth1: <--- start MCP states dump --->
[ 5417.276314] bnx2 0000:01:00.1 eth1: DEBUG: MCP_STATE_P0[0003610e] 
MCP_STATE_P1[0003610e]
[ 5417.276326] bnx2 0000:01:00.1 eth1: DEBUG: MCP mode[0000b880] 
state[80000000] evt_mask[00000500]
[ 5417.276339] bnx2 0000:01:00.1 eth1: DEBUG: pc[0800d7b8] pc[08000cdc] 
instr[00041880]
[ 5417.276349] bnx2 0000:01:00.1 eth1: DEBUG: shmem states:
[ 5417.276358] bnx2 0000:01:00.1 eth1: DEBUG: drv_mb[0d000004] 
fw_mb[00000004] link_status[0000006f]
[ 5417.276369]  drv_pulse_mb[00001485]
[ 5417.276373] bnx2 0000:01:00.1 eth1: DEBUG: 
dev_info_signature[44564903] reset_type[01005254]
[ 5417.276383]  condition[0003610e]
[ 5417.276389] bnx2 0000:01:00.1 eth1: DEBUG: 000001c0: 01005254 
42530000 0003610e 00000000
[ 5417.276402] bnx2 0000:01:00.1 eth1: DEBUG: 000003cc: 44444444 
44444444 44444444 00000a28
[ 5417.276416] bnx2 0000:01:00.1 eth1: DEBUG: 000003dc: 0004ffff 
00000000 00000000 00000000
[ 5417.276430] bnx2 0000:01:00.1 eth1: DEBUG: 000003ec: 00000000 
00000000 00000000 00000000
[ 5417.276440] bnx2 0000:01:00.1 eth1: DEBUG: 0x3fc[0000ffff]
