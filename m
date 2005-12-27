From: Steve Lazaridis <slaz@fortresstech.com>
Subject: ip_sabotage_out crash...
Date: Tue, 27 Dec 2005 10:24:06 -0500
Message-ID: <43B15C96.7000801@fortresstech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <bridge-bounces@lists.osdl.org>
To: netdev@vger.kernel.org, bridge@osdl.org
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Hi,
I'm running on a MIPSbe(AMD au1550) CPU and I'm getting kernel crashes 
when pumping a lot of traffic through two bridges using iperf.

kernel: linux-2.6.13-rc7 ~ from mips-linux.org


The setup is:
[host a]<-->[bridge a]<---->[bridge b]<-->[host b]
host a: iperf client
host b: iperf server

Not sure if it makes a difference, but about 99% of the time the crash
happens on the device that the iperf client is hooked up to.

Has anyone ever seen anything like this before, I've searched the 
mailling lists and didn't find anything specifically to this.  It might 
be something related to my architecture, but I thought I'd try here first.


Any help, or pointers are much appreciated.


Thanks,
Steve

I've pasted the dump below

______________BEGIN DUMP_________________
Unhandled kernel unaligned access in
arch/mips/kernel/unaligned.c::emulate_load_store_insn, line 475[#1]:
Cpu 0
$ 0   : 00000000 80454bc0 c011023c c0114758
$ 4   : 00000004 8038d988 00000000 00000001
$ 8   : c0114758 252e0b3a 00112515 ed370800
$12   : 00000003 00000001 00000000 00000007
$16   : 8038d938 80000000 80454c60 00000001
$20   : 00000000 00000004 8038d988 00000001
$24   : 00000000 2ab0bdf4
$28   : 8038c000 8038d8b0 c01072b0 802ce794
Hi    : 00000015
Lo    : 0000004e
epc   : c0110254 ip_sabotage_out+0x18/0x1c4 [bridge]     Tainted: P
ra    : 802ce794 nf_iterate+0xec/0x11c
Status: 1000fc03    KERNEL EXL IE
Cause : 00800010
BadVA : 0000015d
PrId  : 03030200
Modules linked in: wlan_scan_sta ath_pci ath_rate_atheros wlan ath_hal
bridge pegIO
Process swapper (pid: 0, threadinfo=8038c000, task=8038f138)
Stack : 00000000 00000101 00000101 812a9124 8038d938 80000000 80454c60
00000001
         802ce794 802bc6e8 00000000 8b547ae8 812a9080 813d3ce0 c01072b0
8b527360
         00000004 8038d988 00000010 00000000 c01072b0 00000001 8038d938
80000000
         00000002 802cf0b4 802bc6ac 802bc578 c01072b0 c0107420 00000001
8038d938
         c01072b0 80000000 c0114758 00000000 c01072b0 00000001 00000002
8bcb6000
         ...
Call Trace:
  [<802ce794>] nf_iterate+0xec/0x11c
  [<802bc6e8>] dev_queue_xmit+0x25c/0x2fc
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<802cf0b4>] nf_hook_slow+0xa0/0x1e0
  [<802bc6ac>] dev_queue_xmit+0x220/0x2fc
  [<802bc578>] dev_queue_xmit+0xec/0x2fc
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c0107420>] br_dev_queue_push_xmit+0x170/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c0110188>] br_nf_post_routing+0x128/0x1b0 [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<802ce794>] nf_iterate+0xec/0x11c
  [<8010512c>] do_IRQ+0x24/0x34
  [<80105124>] do_IRQ+0x1c/0x34
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<802cf0b4>] nf_hook_slow+0xa0/0x1e0
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c0107508>] br_forward_finish+0x7c/0x90 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c01072b0>] br_dev_queue_push_xmit+0x0/0x1dc [bridge]
  [<c010f878>] br_nf_forward_finish+0x98/0x168 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c010f7e0>] br_nf_forward_finish+0x0/0x168 [bridge]
  [<c010fa08>] br_nf_forward_ip+0xc0/0x18c [bridge]
  [<c010fa50>] br_nf_forward_ip+0x108/0x18c [bridge]
  [<801012f4>] au1000_IRQ+0x134/0x1a0
  [<c010f7e0>] br_nf_forward_finish+0x0/0x168 [bridge]
  [<80105124>] do_IRQ+0x1c/0x34
  [<802ce794>] nf_iterate+0xec/0x11c
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<802cf0b4>] nf_hook_slow+0xa0/0x1e0
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c0107804>] __br_forward+0x254/0x268 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c010748c>] br_forward_finish+0x0/0x90 [bridge]
  [<c0107a10>] br_forward+0xf8/0x100 [bridge]
  [<c0109200>] br_handle_frame_finish+0x33c/0x640 [bridge]
  [<c0108f0c>] br_handle_frame_finish+0x48/0x640 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c010e8ac>] br_nf_pre_routing_finish+0x10c/0x4ec [bridge]
  [<80101a2c>] intc0_req0_irqdispatch+0x84/0x90
  [<8029821c>] au1000_rx+0x390/0x3f4
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c019e4e0>] zz0dab8b79+0x34/0x20c [ath_hal]
  [<801012f4>] au1000_IRQ+0x134/0x1a0
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<802cf0b4>] nf_hook_slow+0xa0/0x1e0
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<c010f3bc>] br_nf_pre_routing+0x2ec/0x65c [bridge]
  [<c010f3f0>] br_nf_pre_routing+0x320/0x65c [bridge]
  [<8014b088>] handle_IRQ_event+0x6c/0xec
  [<c010e7a0>] br_nf_pre_routing_finish+0x0/0x4ec [bridge]
  [<802ce794>] nf_iterate+0xec/0x11c
  [<8024be20>] memset_partial+0x44/0x6c
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<802cf0b4>] nf_hook_slow+0xa0/0x1e0
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<c0109738>] br_handle_frame+0x234/0x2dc [bridge]
  [<c0196398>] ath_hal_reg_read+0x0/0xb4 [ath_hal]
  [<c01a93b4>] zz002daf00+0xf8/0x56c [ath_hal]
  [<c0108ec4>] br_handle_frame_finish+0x0/0x640 [bridge]
  [<802bcf90>] netif_receive_skb+0x180/0x4ac
  [<c016be80>] ath_rx_poll+0x32c/0xc64 [ath_pci]
  [<c016bd18>] ath_rx_poll+0x1c4/0xc64 [ath_pci]
  [<802bd39c>] process_backlog+0xe0/0x2b8
  [<802bd514>] process_backlog+0x258/0x2b8
  [<80423000>] kernel_entry+0x0/0x7c
  [<802bd63c>] net_rx_action+0xc8/0x248
  [<8012ca4c>] tasklet_action+0xac/0x180
  [<8012c5e4>] __do_softirq+0x114/0x11c
  [<8012c5e4>] __do_softirq+0x114/0x11c
  [<8012c678>] do_softirq+0x8c/0x94
  [<8014b194>] __do_IRQ+0x8c/0x158
  [<8012c678>] do_softirq+0x8c/0x94
  [<8012c72c>] irq_exit+0x4c/0x54
  [<8010512c>] do_IRQ+0x24/0x34
  [<80105124>] do_IRQ+0x1c/0x34
  [<80101ddc>] mips_timer_interrupt+0xec/0x10c
  [<80101d84>] mips_timer_interrupt+0x94/0x10c
  [<80101a2c>] intc0_req0_irqdispatch+0x84/0x90
  [<801012f4>] au1000_IRQ+0x134/0x1a0
  [<80423000>] kernel_entry+0x0/0x7c
  [<80105340>] cpu_idle+0x50/0x68
  [<80105318>] cpu_idle+0x28/0x68
  [<8010042c>] rest_init+0x2c/0x38
  [<804237bc>] start_kernel+0x1e4/0x20c
  [<80423798>] start_kernel+0x1c0/0x20c
  [<80423230>] unknown_bootoption+0x0/0x22c


Code: afb10014  afbf0020  afb00010 <8ce2015c> 00e08821  3c07c010
24e76008  00809021  00c09821
Ke
______________END DUMP_________________
