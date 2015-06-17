From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: ax88179_178a: ethernet to usb dongle disconnect crash
Date: Wed, 17 Jun 2015 05:53:41 -0700
Message-ID: <20150617125341.GB15116@kroah.com>
References: <CA+vmRF6c=fnFzTraqjk0yg59iMe8T6oFNayvGgZcADja8XPWwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Vivek Bhagat <vivek.bhagat89@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:50335 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbbFQMxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 08:53:42 -0400
Content-Disposition: inline
In-Reply-To: <CA+vmRF6c=fnFzTraqjk0yg59iMe8T6oFNayvGgZcADja8XPWwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 10:31:40AM +0530, Vivek Bhagat wrote:
> Hi All,
> 
> I have connected my pc and TV board as below -
> 
> PC (network i/f) <----> ethernet to usb dongle <---> usb port of TV board
> 
> When I power off  my board, i get a kernel crash.
> Please have a look at log attached here.I debug and found that
> unregister_netdev() in usbnet_disconnect() clears net_device object
> and still skb is under processing which tries to access net_device
> object and leads to crash.Dongle is using ax88179_178.ko module.
> 
> Backtrace:
> [1-11856.1782] [<c045ea38>] (fib_compute_spec_dst+0x0/0x17c) from
> [<c04308c0>] (ipv4_pktinfo_prepare+0x38/0x70)
> [1-11856.1880]  r6:00000000 r5:c5d55800 r4:c5d55800
> [1-11856.1926] [<c0430888>] (ipv4_pktinfo_prepare+0x0/0x70) from
> [<c04512d4>] (udp_queue_rcv_skb+0x1c8/0x384)
> [1-11856.2023]  r5:c5d55800 r4:cbdf4380
> [1-11856.2059] [<c045110c>] (udp_queue_rcv_skb+0x0/0x384) from
> [<c0451590>] (flush_stack+0x100/0x118)
> [1-11856.2148]  r7:cd398480 r6:00000000 r5:cbdf4380 r4:c5d55800
> [1-11856.2205] [<c0451490>] (flush_stack+0x0/0x118) from [<c04518b0>]
> (__udp4_lib_mcast_deliver.isra.44+0x308/0x370)
> [1-11856.2308] [<c04515a8>]
> (__udp4_lib_mcast_deliver.isra.44+0x0/0x370) from [<c0451dd0>]
> (__udp4_lib_rcv+0x4b8/0x588)
> [1-11856.2413] [<c0451918>] (__udp4_lib_rcv+0x0/0x588) from
> [<c0451ec0>] (udp_rcv+0x20/0x28)
> [1-11856.2495] [<c0451ea0>] (udp_rcv+0x0/0x28) from [<c042836c>]
> (ip_local_deliver_finish+0x118/0x27c)
> [1-11856.2585] [<c0428254>] (ip_local_deliver_finish+0x0/0x27c) from
> [<c0428988>] (ip_local_deliver+0x8c/0x98)
> [1-11856.2683]  r7:d4b01a40 r6:cd398480 r5:00000000 r4:cd398480
> [1-11856.2740] [<c04288fc>] (ip_local_deliver+0x0/0x98) from
> [<c0428798>] (ip_rcv_finish+0x2c8/0x344)
> [1-11856.2829]  r4:00295a38
> [1-11856.2855] [<c04284d0>] (ip_rcv_finish+0x0/0x344) from
> [<c0428cb8>] (ip_rcv+0x324/0x3f0)
> [1-11856.2936]  r7:d4b01a40 r6:cd398480 r5:d2e8b720 r4:c0737500
> [1-11856.2993] [<c0428994>] (ip_rcv+0x0/0x3f0) from [<c03f69d4>]
> (__netif_receive_skb_core+0x4d0/0x568)
> [1-11856.3084]  r7:00000000 r6:00000000 r5:c0708b34 r4:c070a728
> [1-11856.3141] [<c03f6504>] (__netif_receive_skb_core+0x0/0x568) from
> [<c03f7038>] (__netif_receive_skb+0x20/0x70)
> [1-11856.3242] [<c03f7018>] (__netif_receive_skb+0x0/0x70) from
> [<c03f8584>] (process_backlog+0xec/0x1e8)
> [1-11856.3335]  r5:00000000 r4:d7c828c4
> [1-11856.3371] [<c03f8498>] (process_backlog+0x0/0x1e8) from
> [<c03f82e4>] (net_rx_action+0x104/0x2b8)
> [1-11856.3460] [<c03f81e0>] (net_rx_action+0x0/0x2b8) from
> [<c0044460>] (__do_softirq+0x180/0x304)
> [1-11856.3548] [<c00442e0>] (__do_softirq+0x0/0x304) from [<c0044708>]
> (do_softirq+0x74/0xc4)
> [1-11856.3630] [<c0044694>] (do_softirq+0x0/0xc4) from [<c03f56f0>]
> (netif_rx_ni+0x50/0x78)
> [1-11856.3711]  r7:d1708780 r6:cd399380 r5:00000000 r4:c850a020
> [1-11856.3768] [<c03f56a0>] (netif_rx_ni+0x0/0x78) from [<c03f57ec>]
> (dev_loopback_xmit+0xd4/0xe0)
> [1-11856.3855]  r5:00000000 r4:cd398480
> [1-11856.3891] [<c03f5718>] (dev_loopback_xmit+0x0/0xe0) from
> [<c042da08>] (ip_mc_output+0x114/0x234)
> [1-11856.3980]  r5:00000000 r4:cd398480
> [1-11856.4016] [<c042d8f4>] (ip_mc_output+0x0/0x234) from [<c042d3cc>]
> (ip_local_out+0x38/0x3c)
> [1-11856.4100]  r9:000000c6 r8:d2e8b734 r7:cbdf7800 r6:c0737500 r5:c0737500
> r4:cd399380
> [1-11856.4179] [<c042d394>] (ip_local_out+0x0/0x3c) from [<c042e5bc>]
> (ip_send_skb+0x20/0x88)
> [1-11856.4261]  r5:c0737500 r4:cd399380
> [1-11856.4297] [<c042e59c>] (ip_send_skb+0x0/0x88) from [<c044e400>]
> (udp_send_skb+0x250/0x314)
> [1-11856.4382]  r5:00000000 r4:cd399380
> [1-11856.4417] [<c044e1b0>] (udp_send_skb+0x0/0x314) from [<c04505b4>]
> (udp_sendmsg+0x6a8/0x6d0)
> [1-11856.4503] [<c044ff0c>] (udp_sendmsg+0x0/0x6d0) from [<c04587a8>]
> (inet_sendmsg+0x94/0xc4)
> [1-11856.4586] [<c0458714>] (inet_sendmsg+0x0/0xc4) from [<c03e2624>]
> (sock_sendmsg+0xa0/0xbc)
> [1-11856.4670]  r7:c8406e40 r6:c850bf5c r5:000000be r4:c4cda300
> [1-11856.4726] [<c03e2584>] (sock_sendmsg+0x0/0xbc) from [<c03e3c2c>]
> (___sys_sendmsg.part.16+0x1a0/0x244)
> [1-11856.4820]  r7:c4cda300 r6:00000000 r5:c850be7c r4:00000000
> [1-11856.4877] [<c03e3a8c>] (___sys_sendmsg.part.16+0x0/0x244) from
> [<c03e4db4>] (__sys_sendmsg+0x5c/0x80)
> [1-11856.4971] [<c03e4d58>] (__sys_sendmsg+0x0/0x80) from [<c03e4df0>]
> (SyS_sendmsg+0x18/0x1c)
> [1-11856.5055]  r6:bdfda694 r5:bdfda60c r4:002841c0
> [1-11856.5101] [<c03e4dd8>] (SyS_sendmsg+0x0/0x1c) from [<c00114c0>]
> (ret_fast_syscall+0x0/0x48)

3.10 is really old, please try something more "modern" like 4.0 at the
very least to see if the issue is still there.

thanks,

greg k-h
