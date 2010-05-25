From: Avi Kivity <avi@redhat.com>
Subject: Re: host panic on kernel 2.6.34
Date: Tue, 25 May 2010 12:53:50 +0300
Message-ID: <4BFB9E2E.9020103@redhat.com>
References: <BC00F5384FCFC9499AF06F92E8B78A9E04DCCCE242@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: "Hao, Xudong" <xudong.hao@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397Ab0EYJy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 05:54:29 -0400
In-Reply-To: <BC00F5384FCFC9499AF06F92E8B78A9E04DCCCE242@shsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copying netdev, bridge mailing lists.

On 05/24/2010 11:23 AM, Hao, Xudong wrote:
> Hi all
> I build latest kvm 37dec075a7854f0f550540bf3b9bbeef37c11e2a, based on kernel 2.6.34, after kvm and kvm_intel module loaded, then /etc/init.d/kvm start, a few minutes later, the system will panic.
>
> kernel: 2.6.34
> kvm: 37dec075a7854f0f550540bf3b9bbeef37c11e2a
> qemu-kvm: 69dd59a66aaf56d1e8e4c96d0a0923c9cf8f79a0
>
> BUG: unable to handle kernel NULL pointer dereference at 00000018
> IP: [<f914c05b>] br_mdb_ip_get+0x2e/0x1aa [bridge]
> *pdpt = 0000000035fbb001 *pde = 0000000000000000
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
> Modules linked in: bridge stp autofs4 hidp rfcomm l2cap crc16 bluetooth rfkill ]
>
> Pid: 0, comm: swapper Not tainted 2.6.34 #1 X7DWA/X7DWA
> EIP: 0060:[<f914c05b>] EFLAGS: 00010246 CPU: 0
> EIP is at br_mdb_ip_get+0x2e/0x1aa [bridge]
> EAX: c5801d40 EBX: c5801d40 ECX: faffffef EDX: 00000000
> ESI: f67e03c0 EDI: f5249200 EBP: c5801c94 ESP: c5801c80
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c5801000 task=c07f2fe0 task.ti=c07de000)
> Stack:
>   c5801d40 00000000 c5801d40 f67e03c0 f5249200 c5801cb0 f914c6fd fff90006
> <0>  f67e0940 f6326740 f627e064 f67e03c0 c5801d78 f914dd0c f76af140 f6326740
> <0>  f5249200 f67e03c0 00000014 f6326758 c5801d54 c08eb440 c5801cf4 c5801d00
> Call Trace:
>   [<f914c6fd>] ? br_multicast_leave_group+0x52/0x128 [bridge]
>   [<f914dd0c>] ? br_multicast_rcv+0x6dc/0xe90 [bridge]
>   [<c0650420>] ? fib_lookup+0x2c/0x3a
>   [<c064cd15>] ? fib_validate_source+0x29d/0x2b4
>   [<c0621175>] ? nf_hook_slow+0x3b/0x92
>   [<f9147b39>] ? br_handle_frame_finish+0x53/0x17e [bridge]
>   [<f914b880>] ? br_nf_pre_routing_finish+0x264/0x27c [bridge]
>   [<c0621175>] ? nf_hook_slow+0x3b/0x92
>   [<f914b61c>] ? br_nf_pre_routing_finish+0x0/0x27c [bridge]
>   [<f914bf6f>] ? br_nf_pre_routing+0x553/0x570 [bridge]
>   [<c0621107>] ? nf_iterate+0x2f/0x62
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<c0621175>] ? nf_hook_slow+0x3b/0x92
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<f9147dda>] ? br_handle_frame+0x176/0x198 [bridge]
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<c060643b>] ? __netif_receive_skb+0x29a/0x37e
>   [<c0607023>] ? dev_gro_receive+0xfd/0x1d2
>   [<c0606e03>] ? netif_receive_skb+0x61/0x67
>   [<c0607199>] ? __napi_gro_receive+0xa1/0xba
>   [<c0606e7e>] ? napi_skb_finish+0x1e/0x33
>   [<c0607201>] ? napi_gro_receive+0x20/0x24
>   [<f8867cfc>] ? igb_poll+0x706/0xa39 [igb]
>   [<c06093b2>] ? net_rx_action+0x97/0x13b
>   [<c0430641>] ? __do_softirq+0x80/0xf4
>   [<c04305c1>] ? __do_softirq+0x0/0xf4
>   <IRQ>
>   [<c04305bf>] ? irq_exit+0x29/0x2b
>   [<c040373e>] ? do_IRQ+0x85/0x9b
>   [<c0402ca9>] ? common_interrupt+0x29/0x30
>   [<c0407c4f>] ? mwait_idle+0x4c/0x52
>   [<c0401a08>] ? cpu_idle+0x3a/0x4e
>   [<c066cf16>] ? rest_init+0x62/0x64
>   [<c08248dd>] ? start_kernel+0x2c2/0x2c7
>   [<c08240b3>] ? i386_start_kernel+0xb3/0xb8
> Code: 57 56 53 83 ec 08 89 45 f0 89 55 ec 8b 42 10 66 83 f8 08 74 0e 31 db 66 3
> EIP: [<f914c05b>] br_mdb_ip_get+0x2e/0x1aa [bridge] SS:ESP 0068:c5801c80
> CR2: 0000000000000018
> ---[ end trace 907f878ab4cd8031 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Pid: 0, comm: swapper Tainted: G      D     2.6.34 #1
> Call Trace:
>   [<c042c31b>] panic+0x3e/0xaa
>   [<c0681caa>] oops_end+0x8c/0x9b
>   [<c041e710>] no_context+0x153/0x15d
>   [<c041e8a2>] __bad_area_nosemaphore+0xe5/0xed
>   [<c041e90e>] bad_area_nosemaphore+0xd/0x13
>   [<c06838b0>] do_page_fault+0x375/0x37d
>   [<c0650420>] ? fib_lookup+0x2c/0x3a
>   [<c0624431>] ? ip_route_input_common+0x695/0xf2f
>   [<c068353b>] ? do_page_fault+0x0/0x37d
>   [<c06813d6>] error_code+0x66/0x6c
>   [<c068353b>] ? do_page_fault+0x0/0x37d
>   [<f914c05b>] ? br_mdb_ip_get+0x2e/0x1aa [bridge]
>   [<f914c6fd>] br_multicast_leave_group+0x52/0x128 [bridge]
>   [<f914dd0c>] br_multicast_rcv+0x6dc/0xe90 [bridge]
>   [<c0650420>] ? fib_lookup+0x2c/0x3a
>   [<c064cd15>] ? fib_validate_source+0x29d/0x2b4
>   [<c0621175>] ? nf_hook_slow+0x3b/0x92
>   [<f9147b39>] br_handle_frame_finish+0x53/0x17e [bridge]
>   [<f914b880>] br_nf_pre_routing_finish+0x264/0x27c [bridge]
>   [<c0621175>] ? nf_hook_slow+0x3b/0x92
>   [<f914b61c>] ? br_nf_pre_routing_finish+0x0/0x27c [bridge]
>   [<f914bf6f>] br_nf_pre_routing+0x553/0x570 [bridge]
>   [<c0621107>] nf_iterate+0x2f/0x62
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<c0621175>] nf_hook_slow+0x3b/0x92
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<f9147dda>] br_handle_frame+0x176/0x198 [bridge]
>   [<f9147ae6>] ? br_handle_frame_finish+0x0/0x17e [bridge]
>   [<c060643b>] __netif_receive_skb+0x29a/0x37e
>   [<c0607023>] ? dev_gro_receive+0xfd/0x1d2
>   [<c0606e03>] netif_receive_skb+0x61/0x67
>   [<c0607199>] ? __napi_gro_receive+0xa1/0xba
>   [<c0606e7e>] napi_skb_finish+0x1e/0x33
>   [<c0607201>] napi_gro_receive+0x20/0x24
>   [<f8867cfc>] igb_poll+0x706/0xa39 [igb]
>   [<c06093b2>] net_rx_action+0x97/0x13b
>   [<c0430641>] __do_softirq+0x80/0xf4
>   [<c04305c1>] ? __do_softirq+0x0/0xf4
>   <IRQ>   [<c04305bf>] ? irq_exit+0x29/0x2b
>   [<c040373e>] ? do_IRQ+0x85/0x9b
>   [<c0402ca9>] ? common_interrupt+0x29/0x30
>   [<c0407c4f>] ? mwait_idle+0x4c/0x52
>   [<c0401a08>] ? cpu_idle+0x3a/0x4e
>   [<c066cf16>] ? rest_init+0x62/0x64
>   [<c08248dd>] ? start_kernel+0x2c2/0x2c7
>   [<c08240b3>] ? i386_start_kernel+0xb3/0xb8
>
> Best Regards,
> Xudong Hao
>    


-- 
error compiling committee.c: too many arguments to function

