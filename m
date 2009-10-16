From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: e1000_clean_tx_irq: Detected Tx Unit Hang
Date: Fri, 16 Oct 2009 06:24:32 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0910160600370.2463@praktifix.dwd.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755365AbZJPGg3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

I have received the following error on a busy network:

    Oct 15 22:01:13 hermes kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
    Oct 15 22:01:13 hermes kernel:  Tx Queue             <0>
    Oct 15 22:01:13 hermes kernel:  TDH                  <ff>
    Oct 15 22:01:13 hermes kernel:  TDT                  <ee>
    Oct 15 22:01:13 hermes kernel:  next_to_use          <ee>
    Oct 15 22:01:13 hermes kernel:  next_to_clean        <fe>
    Oct 15 22:01:13 hermes kernel: buffer_info[next_to_clean]
    Oct 15 22:01:13 hermes kernel:  time_stamp           <1031cfe6d>
    Oct 15 22:01:13 hermes kernel:  next_to_watch        <2>
    Oct 15 22:01:13 hermes kernel:  jiffies              <1031d0000>
    Oct 15 22:01:13 hermes kernel:  next_to_watch.status <0>
    Oct 15 22:01:15 hermes kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
    Oct 15 22:01:15 hermes kernel:  Tx Queue             <0>
    Oct 15 22:01:15 hermes kernel:  TDH                  <ff>
    Oct 15 22:01:15 hermes kernel:  TDT                  <ee>
    Oct 15 22:01:15 hermes kernel:  next_to_use          <ee>
    Oct 15 22:01:15 hermes kernel:  next_to_clean        <fe>
    Oct 15 22:01:15 hermes kernel: buffer_info[next_to_clean]
    Oct 15 22:01:15 hermes kernel:  time_stamp           <1031cfe6d>
    Oct 15 22:01:15 hermes kernel:  next_to_watch        <2>
    Oct 15 22:01:15 hermes kernel:  jiffies              <1031d01f4>
    Oct 15 22:01:15 hermes kernel:  next_to_watch.status <0>
    Oct 15 22:01:17 hermes kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
    Oct 15 22:01:17 hermes kernel:  Tx Queue             <0>
    Oct 15 22:01:17 hermes kernel:  TDH                  <ff>
    Oct 15 22:01:17 hermes kernel:  TDT                  <ee>
    Oct 15 22:01:17 hermes kernel:  next_to_use          <ee>
    Oct 15 22:01:17 hermes kernel:  next_to_clean        <fe>
    Oct 15 22:01:17 hermes kernel: buffer_info[next_to_clean]
    Oct 15 22:01:17 hermes kernel:  time_stamp           <1031cfe6d>
    Oct 15 22:01:17 hermes kernel:  next_to_watch        <2>
    Oct 15 22:01:17 hermes kernel:  jiffies              <1031d03e8>
    Oct 15 22:01:17 hermes kernel:  next_to_watch.status <0>
    Oct 15 22:01:18 hermes kernel: ------------[ cut here ]------------
    Oct 15 22:01:18 hermes kernel: WARNING: at net/sched/sch_generic.c:246 dev_watchdog+0x143/0x1eb()
    Oct 15 22:01:18 hermes kernel: Hardware name: PRIMERGY RX300 S4
    Oct 15 22:01:18 hermes kernel: NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
    Oct 15 22:01:18 hermes kernel: Modules linked in: coretemp ipmi_devintf ipmi_si ipmi_msghandler bonding nf_conntrack_ftp binfmt_misc usbhid i2c_i801 i5000_edac i2c_core i5k_amb uhci_hcd ehci_hcd sg usbcore [last unloaded: microcode]
    Oct 15 22:01:18 hermes kernel: Pid: 0, comm: swapper Not tainted 2.6.31.4 #4
    Oct 15 22:01:18 hermes kernel: Call Trace:
    Oct 15 22:01:18 hermes kernel: <IRQ>  [<ffffffff810686bf>] warn_slowpath_common+0x88/0xb6
    Oct 15 22:01:18 hermes kernel: [<ffffffff81068770>] warn_slowpath_fmt+0x4b/0x61
    Oct 15 22:01:18 hermes kernel: [<ffffffff813995fb>] ? netdev_drivername+0x52/0x70
    Oct 15 22:01:18 hermes kernel: [<ffffffff813ac5dc>] dev_watchdog+0x143/0x1eb
    Oct 15 22:01:18 hermes kernel: [<ffffffff8107ba1f>] ? __queue_work+0x44/0x61
    Oct 15 22:01:18 hermes kernel: [<ffffffff810731d1>] run_timer_softirq+0x1a8/0x238
    Oct 15 22:01:18 hermes kernel: [<ffffffff8108af33>] ? clockevents_program_event+0x88/0xa5
    Oct 15 22:01:18 hermes kernel: [<ffffffff8106e6db>] __do_softirq+0xab/0x160
    Oct 15 22:01:18 hermes kernel: [<ffffffff8102cdac>] call_softirq+0x1c/0x28
    Oct 15 22:01:18 hermes kernel: [<ffffffff8102ee55>] do_softirq+0x51/0xae
    Oct 15 22:01:18 hermes kernel: [<ffffffff8106e2f4>] irq_exit+0x52/0xa3
    Oct 15 22:01:18 hermes kernel: [<ffffffff810442e7>] smp_apic_timer_interrupt+0x9c/0xc1
    Oct 15 22:01:18 hermes kernel: [<ffffffff8102c773>] apic_timer_interrupt+0x13/0x20
    Oct 15 22:01:18 hermes kernel: <EOI>  [<ffffffff81274aea>] ? acpi_idle_enter_simple+0x17e/0x1c6
    Oct 15 22:01:18 hermes kernel: [<ffffffff81274ae3>] ? acpi_idle_enter_simple+0x177/0x1c6
    Oct 15 22:01:18 hermes kernel: [<ffffffff8137a924>] ? cpuidle_idle_call+0x9b/0xe7
    Oct 15 22:01:18 hermes kernel: [<ffffffff8102aeb4>] ? cpu_idle+0xb0/0xf3
    Oct 15 22:01:18 hermes kernel: [<ffffffff81421b36>] ? start_secondary+0x1b8/0x1d3
    Oct 15 22:01:18 hermes kernel: ---[ end trace 5d760977cd95430f ]---
    Oct 15 22:01:18 hermes kernel: bonding: bond0: link status definitely down for interface eth0, disabling it
    Oct 15 22:01:18 hermes kernel: bonding: bond0: making interface eth2 the new active one.
    Oct 15 22:01:21 hermes kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
    Oct 15 22:01:21 hermes kernel: bonding: bond0: link status definitely up for interface eth0.

This happened with a plain kernel.org kernel 2.6.31.4. The ethernet card
is a PCI-X card (ie. using the e1000 driver), here the output of lspci:

    05:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
            Subsystem: Intel Corporation Device 118a
            Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
            Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
            Latency: 64 (63750ns min), Cache Line Size: 64 bytes
            Interrupt: pin A routed to IRQ 24
            Region 0: Memory at f9280000 (64-bit, non-prefetchable) [size=128K]
            Region 2: Memory at f9240000 (64-bit, non-prefetchable) [size=256K]
            Region 4: I/O ports at 4000 [size=64]
            [virtual] Expansion ROM at c0000000 [disabled] [size=256K]
            Capabilities: [dc] Power Management version 2
                    Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                    Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
            Capabilities: [e4] PCI-X non-bridge device
                    Command: DPERE- ERO+ RBC=512 OST=1
                    Status: Dev=05:04.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
            Capabilities: [f0] MSI: Enable- Count=1/1 Maskable- 64bit+
                    Address: 0000000000000000  Data: 0000
            Kernel driver in use: e1000

    05:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
            Subsystem: Intel Corporation Device 118a
            Physical Slot: 4
            Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
            Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
            Latency: 64 (63750ns min), Cache Line Size: 64 bytes
            Interrupt: pin B routed to IRQ 25
            Region 0: Memory at f92a0000 (64-bit, non-prefetchable) [size=128K]
            Region 2: Memory at f9300000 (64-bit, non-prefetchable) [size=256K]
            Region 4: I/O ports at 4400 [size=64]
            [virtual] Expansion ROM at c0040000 [disabled] [size=256K]
            Capabilities: [dc] Power Management version 2
                    Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                    Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
            Capabilities: [e4] PCI-X non-bridge device
                    Command: DPERE- ERO+ RBC=512 OST=1
                    Status: Dev=05:04.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
            Capabilities: [f0] MSI: Enable- Count=1/1 Maskable- 64bit+
                    Address: 0000000000000000  Data: 0000
            Kernel driver in use: e1000

Googling I see that in the past that there are lots of reports, but not
recently. From those reports I read one should disable
tcp-segmentation-offload, which I did as a first step. Anything else
I can do? Or what other information can I provide to help solve
this problem?

Thanks,
Holger

PS: Please CC me since I am not subscribed.
