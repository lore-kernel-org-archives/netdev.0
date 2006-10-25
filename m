From: "Richard Bollinger" <rabollinger@gmail.com>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte GA-7VCSV)
Date: Wed, 25 Oct 2006 15:29:33 -0400
Message-ID: <7744a2840610251229u198602f5mb97c5ab50dde2362@mail.gmail.com>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <7744a2840610250602m4b589fedq3a4e89f26fc18794@mail.gmail.com>
	 <1161794387.3613.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:17176 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750877AbWJYT3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 15:29:37 -0400
Received: by ug-out-1314.google.com with SMTP id 32so193472ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 12:29:34 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1161794387.3613.3.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/06, Michael Chan <mchan@broadcom.com> wrote:
> This confirms that it's some kind of interrupt problem as David had
> suggested, at least on eth2.  You can try booting with "noapic" to see
> if it works if you haven't got the patch from Adrian Bunk yet.
>
No joy.  Here's the dmesg after boot w/ noapic, modprobe tg3 and
ifconfig eth1 up & ifconfig eth2 up:
tg3.c:v3.65 (August 07, 2006)
PCI: Found IRQ 11 for device 0000:08:00.0
PCI: Sharing IRQ 11 with 0000:00:00.0
PCI: Sharing IRQ 11 with 0000:00:02.0
PCI: Sharing IRQ 11 with 0000:00:03.0
PCI: Sharing IRQ 11 with 0000:00:1c.1
PCI: Sharing IRQ 11 with 0000:01:00.0
PCI: Sharing IRQ 11 with 0000:02:00.0
PCI: Sharing IRQ 11 with 0000:03:00.0
PCI: Sharing IRQ 11 with 0000:05:01.0
PCI: Sharing IRQ 11 with 0000:0b:01.0
PCI: Setting latency timer of device 0000:08:00.0 to 64
eth1: Tigon3 [partno(BCM95789) rev 4101 PHY(5750)] (PCI Express)
10/100/1000BaseT Ethernet 00:16:e6:80:b1:3e
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth1: dma_rwctrl[76180000] dma_mask[64-bit]
PCI: Setting latency timer of device 0000:09:00.0 to 64
eth2: Tigon3 [partno(BCM95789) rev 4101 PHY(5750)] (PCI Express)
10/100/1000BaseT Ethernet 00:16:e6:80:b1:3f
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth2: dma_rwctrl[76180000] dma_mask[64-bit]
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is on for TX and on for RX.
tg3: eth2: Link is up at 1000 Mbps, full duplex.
tg3: eth2: Flow control is on for TX and on for RX.
irq 9: nobody cared (try booting with the "irqpoll" option)
 [<c013d41a>] __report_bad_irq+0x2a/0x8f
 [<c013d50f>] note_interrupt+0x76/0xef
 [<c013cbc3>] __do_IRQ+0xf0/0xfd
 [<c0105515>] do_IRQ+0x31/0x69
 [<c010387e>] common_interrupt+0x1a/0x20
 [<c0120e11>] __do_softirq+0x63/0xeb
 [<c0120ed3>] do_softirq+0x3a/0x3c
 [<c010551a>] do_IRQ+0x36/0x69
 [<c010387e>] common_interrupt+0x1a/0x20
 [<c0124e5b>] del_timer_sync+0x1/0x1d
 [<c0381998>] schedule_timeout+0x60/0xaa
 [<c01260eb>] process_timeout+0x0/0x9
 [<c01735ac>] do_select+0x1cc/0x349
 [<c0173292>] __pollwait+0x0/0x69
 [<c011644e>] default_wake_function+0x0/0x12
 [<c011644e>] default_wake_function+0x0/0x12
 [<c011644e>] default_wake_function+0x0/0x12
 [<c011644e>] default_wake_function+0x0/0x12
 [<c011644e>] default_wake_function+0x0/0x12
 [<c011644e>] default_wake_function+0x0/0x12
 [<c035609e>] fn_hash_lookup+0xb3/0xbc
 [<c035609e>] fn_hash_lookup+0xb3/0xbc
 [<c021e8a0>] copy_to_user+0x42/0x5c
 [<c02efdf2>] memcpy_toiovec+0x4a/0x5f
 [<c02f03e7>] skb_copy_datagram_iovec+0x50/0x20c
 [<c02f02f6>] skb_recv_datagram+0xbb/0xce
 [<c02ed49c>] kfree_skbmem+0x61/0x86
 [<c0349ced>] udp_recvmsg+0x1ca/0x251
 [<c02ec6dc>] sock_common_recvmsg+0x57/0x72
 [<c02e870d>] sock_recvmsg+0x104/0x11e
 [<c021e908>] copy_from_user+0x4e/0x82
 [<c0173962>] core_sys_select+0x239/0x3b1
 [<c01303e4>] autoremove_wake_function+0x0/0x57
 [<c021e8a0>] copy_to_user+0x42/0x5c
 [<c02e7fb9>] move_addr_to_user+0x5c/0x67
 [<c02e9d1d>] sys_recvfrom+0x120/0x162
 [<f8a979d8>] tg3_rx+0x13d/0x3f3 [tg3]
 [<f8a9371e>] tg3_restart_ints+0x23/0x87 [tg3]
 [<c0173b7e>] sys_select+0xa4/0x1be
 [<c0128b8d>] sys_rt_sigprocmask+0x82/0x10c
 [<c0102ef7>] syscall_call+0x7/0xb
handlers:
[<f8a98093>] (tg3_interrupt_tagged+0x0/0xc2 [tg3])
Disabling IRQ #9
tg3: eth1: Link is down.
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is on for TX and on for RX.
tg3: eth2: Link is down.
tg3: eth2: Link is up at 1000 Mbps, full duplex.
tg3: eth2: Flow control is on for TX and on for RX.
irq 9: nobody cared (try booting with the "irqpoll" option)
 [<c013d41a>] __report_bad_irq+0x2a/0x8f
 [<c013d50f>] note_interrupt+0x76/0xef
 [<c013cbc3>] __do_IRQ+0xf0/0xfd
 [<c0105515>] do_IRQ+0x31/0x69
 [<c010e522>] smp_apic_timer_interrupt+0x69/0x75
 [<c010387e>] common_interrupt+0x1a/0x20
 [<c012007b>] sys_setitimer+0xaa/0xb7
 [<c013ca92>] handle_IRQ_event+0x1e/0x5f
 [<c0107730>] mask_and_ack_8259A+0x1d/0xde
 [<c013cb61>] __do_IRQ+0x8e/0xfd
 [<c0105515>] do_IRQ+0x31/0x69
 [<c010e522>] smp_apic_timer_interrupt+0x69/0x75
 [<c010387e>] common_interrupt+0x1a/0x20
 [<c0120e11>] __do_softirq+0x63/0xeb
 [<c0120ed3>] do_softirq+0x3a/0x3c
 [<c010551a>] do_IRQ+0x36/0x69
 [<c010387e>] common_interrupt+0x1a/0x20
 [<c0380ee3>] schedule+0x3f7/0x741
 [<c03819e0>] schedule_timeout+0xa8/0xaa
 [<c0120e87>] __do_softirq+0xd9/0xeb
 [<c0130322>] prepare_to_wait_exclusive+0x20/0x68
 [<c02f01f9>] wait_for_packet+0xf5/0x137
 [<c01303e4>] autoremove_wake_function+0x0/0x57
 [<c01303e4>] autoremove_wake_function+0x0/0x57
 [<c02f02d0>] skb_recv_datagram+0x95/0xce
 [<c036dcdf>] packet_recvmsg+0x6b/0x1b3
 [<c02e870d>] sock_recvmsg+0x104/0x11e
 [<f8a97d95>] tg3_poll+0x107/0x1b6 [tg3]
 [<c0121124>] tasklet_action+0x76/0xcc
 [<c01303e4>] autoremove_wake_function+0x0/0x57
 [<c021e8a0>] copy_to_user+0x42/0x5c
 [<c02e7fb9>] move_addr_to_user+0x5c/0x67
 [<c02e9ce1>] sys_recvfrom+0xe4/0x162
 [<c014e48a>] do_no_page+0x1eb/0x31a
 [<c021e8a0>] copy_to_user+0x42/0x5c
 [<c02ec5f8>] sock_get_timestamp+0x4a/0x7d
 [<c02e8dee>] sock_ioctl+0xb8/0x1b6
 [<c02ea59a>] sys_socketcall+0x1bc/0x256
 [<c0102ef7>] syscall_call+0x7/0xb
handlers:
[<f8a98093>] (tg3_interrupt_tagged+0x0/0xc2 [tg3])
Disabling IRQ #9

# ethtool -t eth1
The test result is FAIL
The test extra info:
nvram test     (online) 0
link test      (online) 0
register test  (offline) 0
memory test    (offline) 0
loopback test  (offline) 0
interrupt test (offline) 1

# ethtool -t eth2
The test result is FAIL
The test extra info:
nvram test     (online) 0
link test      (online) 0
register test  (offline) 0
memory test    (offline) 0
loopback test  (offline) 0
interrupt test (offline) 1

Shortly thereafter it locked up solid.  I tried a reboot with noapic &
irqpoll, but didn't get any further.  I tried a repeat performance
with just noapic and this time the NICs never came up and gave these
test results:
# ethtool -t eth1
The test result is FAIL
The test extra info:
nvram test     (online) 0
link test      (online) 1
register test  (offline) 0
memory test    (offline) 0
loopback test  (offline) 0
interrupt test (offline) 1

# ethtool -t eth2
The test result is FAIL
The test extra info:
nvram test     (online) 0
link test      (online) 1
register test  (offline) 0
memory test    (offline) 0
loopback test  (offline) 3
interrupt test (offline) 1
