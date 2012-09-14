From: Marti Raudsepp <marti-HlJQ7cSfIDjYtjvyW6yDsg@public.gmane.org>
Subject: tulip Ethernet driver messes up USB keyboard
Date: Fri, 14 Sep 2012 12:49:45 +0300
Message-ID: <CABRT9RCWU1RqpAay9iWPKwduejvkdk_CA2P_gV70iiEE2FS5HQ@mail.gmail.com>
References: <CABRT9RDdbqz6iscOz7BYwEQPOo8xfstfUZyBqVw44gmPsauLTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Kernel hackers <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux network list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABRT9RDdbqz6iscOz7BYwEQPOo8xfstfUZyBqVw44gmPsauLTg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi lists,

After installing an old 100Mbit PCI Ethernet card to my machine, it has
complained a few times about spurious interrupts ("nobody cared") at a
random time of the day. After the oops is reported, my USB keyboard (HP
smart card keyboard) stops working properly -- it has lots of delay, it
misses some keystrokes and also causes "stuck keys". Strangely enough my USB
mouse continues to work without problems. Apparently the USB controller and
the Ethernet card share an interrupt line. Un-/replugging the keyboard does
not help.

So far I have simply rebooted to fix the issue. I haven't been able to
reproduce this on will despite my best attempts.

The Ethernet card is driven by the tulip driver and is listed as "ADMtek
NC100 Network Everywhere Fast Ethernet 10/100 (rev 11)" in lspci. My
motherboard uses the Intel H77 chipset (ASRock H77 Pro4/MVP)

Here are two slightly different examples of the oops report; the effect is
the same:

kernel: irq 16: nobody cared (try booting with the "irqpoll" option)
kernel: Pid: 0, comm: swapper/2 Not tainted 3.5.3-1-ARCH #1
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff810d4d3d>] __report_bad_irq+0x3d/0xe0
kernel:  [<ffffffff810d5033>] note_interrupt+0x1a3/0x1f0
kernel:  [<ffffffff810d292f>] handle_irq_event_percpu+0xbf/0x260
kernel:  [<ffffffff810d2b18>] handle_irq_event+0x48/0x70
kernel:  [<ffffffff810d5b4a>] handle_fasteoi_irq+0x5a/0x100
kernel:  [<ffffffff810160c2>] handle_irq+0x22/0x40
kernel:  [<ffffffff81484cea>] do_IRQ+0x5a/0xe0
kernel:  [<ffffffff8147c12a>] common_interrupt+0x6a/0x6a
kernel:  <EOI>  [<ffffffffa02d8f01>] ? acpi_idle_enter_c1+0xda/0x104
[processor]
kernel:  [<ffffffffa02d8edc>] ? acpi_idle_enter_c1+0xb5/0x104 [processor]
kernel:  [<ffffffff8134f159>] cpuidle_enter+0x19/0x20
kernel:  [<ffffffff8134f7a6>] cpuidle_idle_call+0xa6/0x330
kernel:  [<ffffffff8101daaf>] cpu_idle+0xbf/0x130
kernel:  [<ffffffff8146a19b>] start_secondary+0x203/0x20a
kernel: handlers:
kernel: [<ffffffffa012c0b0>] usb_hcd_irq [usbcore]
kernel: [<ffffffffa023b1c0>] tulip_interrupt [tulip]
kernel: Disabling IRQ #16

kernel: irq 16: nobody cared (try booting with the "irqpoll" option)
kernel: Pid: 0, comm: swapper/0 Not tainted 3.5.3-1-ARCH #1
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff810d4d3d>] __report_bad_irq+0x3d/0xe0
kernel:  [<ffffffff810d5033>] note_interrupt+0x1a3/0x1f0
kernel:  [<ffffffff810d292f>] handle_irq_event_percpu+0xbf/0x260
kernel:  [<ffffffff810d2b18>] handle_irq_event+0x48/0x70
kernel:  [<ffffffff810d5b4a>] handle_fasteoi_irq+0x5a/0x100
kernel:  [<ffffffff810160c2>] handle_irq+0x22/0x40
kernel:  [<ffffffff81484cea>] do_IRQ+0x5a/0xe0
kernel:  [<ffffffff8147c12a>] common_interrupt+0x6a/0x6a
kernel:  <EOI>  [<ffffffffa01b6f01>] ? acpi_idle_enter_c1+0xda/0x104
[processor]
kernel:  [<ffffffffa01b6edc>] ? acpi_idle_enter_c1+0xb5/0x104 [processor]
kernel:  [<ffffffff8134f159>] cpuidle_enter+0x19/0x20
kernel:  [<ffffffff8134f7a6>] cpuidle_idle_call+0xa6/0x330
kernel:  [<ffffffff8101daaf>] cpu_idle+0xbf/0x130
kernel:  [<ffffffff81456fbc>] rest_init+0x80/0x84
kernel:  [<ffffffff818bbc35>] start_kernel+0x3c1/0x3ce
kernel:  [<ffffffff818bb673>] ? repair_env_string+0x5e/0x5e
kernel:  [<ffffffff818bb356>] x86_64_start_reservations+0x131/0x135
kernel:  [<ffffffff818bb45a>] x86_64_start_kernel+0x100/0x10f
kernel: handlers:
kernel: [<ffffffffa012c0b0>] usb_hcd_irq [usbcore]
kernel: [<ffffffffa02b41c0>] tulip_interrupt [tulip]
kernel: Disabling IRQ #16

These are after a fresh reboot...

% lspci |grep Eth
03:00.0 Ethernet controller: ADMtek NC100 Network Everywhere Fast Ethernet
10/100 (rev 11)
04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B
PCI Express Gigabit Ethernet controller (rev 06)

% dmesg |egrep -i 'eth|tulip'
[    7.868120] tulip: Linux Tulip driver version 1.1.15 (Feb 27, 2007)
[    7.868146] tulip: tulip_init_one: Enabled WOL support for AN983B
[    7.870487] tulip0:  MII transceiver #1 config 1000 status 786d
advertising 05e1
[    7.893274] net eth0: ADMtek Comet rev 17 at Port 0xe000,
00:06:25:48:7f:16, IRQ 16
[    7.902994] systemd-udevd[162]: renamed network interface eth0 to eth1
[    7.989822] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    7.990148] r8169 0000:04:00.0: eth0: RTL8168evl/8111evl at
0xffffc90005798000, bc:5f:f4:44:29:6c, XID 0c900800 IRQ 47
[    7.990150] r8169 0000:04:00.0: eth0: jumbo features [frames: 9200 bytes,
tx checksumming: ko]
[   16.032206] r8169 0000:04:00.0: eth0: link down
[   16.032568] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   18.287417] r8169 0000:04:00.0: eth0: link up
[   18.287761] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   18.437518] tulip 0000:03:00.0: eth1: tulip_stop_rxtx() failed (CSR5
0xfc664010 CSR6 0xff972113)
[   18.437530] net eth1: Setting full-duplex based on MII#1 link partner
capability of 45e1

Somewhat suspect is the "tulip_stop_rxtx() failed" line. I also get that
line every time I stop the interface (using ip link set eth1 down):
Sep 14 12:40:11 wrx kernel: tulip 0000:03:00.0: eth1: tulip_stop_rxtx()
failed (CSR5 0xfc664010 CSR6 0xff972113)
Sep 14 12:40:11 wrx kernel: net eth1: Setting full-duplex based on MII#1
link partner capability of 45e1
Sep 14 12:40:12 wrx NetworkManager[386]: <info> (eth1): carrier now OFF
(device state 100, deferring action for 4 seconds)
Sep 14 12:40:12 wrx kernel: tulip 0000:03:00.0: eth1: tulip_stop_rxtx()
failed (CSR5 0xfc07c013 CSR6 0xff970111)

% cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3
  0:         48          0          0          0   IO-APIC-edge      timer
  1:          2          1          0          0   IO-APIC-edge      i8042
  8:        164          5          2          0   IO-APIC-edge      rtc0
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          3          0          1          0   IO-APIC-edge      i8042
 16:        141        346    8067481       2394   IO-APIC-fasteoi
ehci_hcd:usb1, eth1
 23:        319      18623       7406      31659   IO-APIC-fasteoi
ehci_hcd:usb2
 40:          0          0          0          0   PCI-MSI-edge      PCIe
PME
 41:          0          0          0          0   PCI-MSI-edge      PCIe
PME
 42:          0          0          0          0   PCI-MSI-edge      PCIe
PME
 43:      22382      61895      31816      10217   PCI-MSI-edge      ahci
 44:          0          0          0          0   PCI-MSI-edge      ahci
 45:          0          0          0          0   PCI-MSI-edge
xhci_hcd
 46:         12          1          0          0   PCI-MSI-edge      mei
 47:          6          2          2      32904   PCI-MSI-edge      eth0
 48:      75136      39014      54183      22566   PCI-MSI-edge      i915
 49:        267        295        254         57   PCI-MSI-edge
snd_hda_intel
NMI:      40906      21860      26792      17063   Non-maskable interrupts
LOC:     362056     362594     377195     364303   Local timer interrupts
SPU:          0          0          0          0   Spurious interrupts
PMI:      40906      21860      26792      17063   Performance monitoring
interrupts
IWI:          6          3          3          2   IRQ work interrupts
RTR:          3          0          0          0   APIC ICR read retries
RES:     241774      18622      10902       4227   Rescheduling interrupts
CAL:        108        116        119        139   Function call interrupts
TLB:      26279      11870      16395      25314   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
THR:          0          0          0          0   Threshold APIC interrupts
MCE:          0          0          0          0   Machine check exceptions
MCP:         11         11         11         11   Machine check polls
ERR:          0
MIS:          0


Regards,
Marti
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
