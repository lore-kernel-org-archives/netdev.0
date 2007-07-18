From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access
 of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 00:52:53 -0700
Message-ID: <20070718005253.942f0464.akpm@linux-foundation.org>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, bart.vanassche@gmail.com
To: netdev@vger.kernel.org, Eugene Surovegin <ebs@ebshome.net>,
	linuxppc-embedded@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40930 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbXGRHxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 03:53:35 -0400
In-Reply-To: <bug-8778-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 00:07:50 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8778
> 
>            Summary: Ocotea board: kernel reports access of bad area during
>                     boot with DEBUG_SLAB=y
>            Product: Platform Specific/Hardware
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: PPC-32
>         AssignedTo: platform_ppc-32@kernel-bugs.osdl.org
>         ReportedBy: bart.vanassche@gmail.com
> 
> 
> Most recent kernel where this bug did not occur: not known - was probably
> already an issue in 2.6.10
> Distribution: not relevant for this issue.
> Hardware Environment: AMCC Ocotea board
> Software Environment: not relevant for this issue.
> Problem Description: see title.
> 
> Steps to reproduce:
> 1. Compile the 2.6.22 kernel with the attached .config
> 2. Boot an Ocotea  board with this kernel.
> 3. Observe the output that appears on the serial console.
> 
> U-Boot 1.1.1 (Nov 10 2005 - 16:29:34)
> 
> IBM PowerPC 440 GUNKNOWN (PVR=51b21892)
> Board: IBM 440GX Evaluation Board
>         VCO: 1066 MHz
>         CPU: 533 MHz
>         PLB: 152 MHz
>         OPB: 76 MHz
>         EPB: 76 MHz
> I2C:   ready
> DRAM:  I2c read: failed 4
> I2c read: failed 4
> 256 MB
> FLASH:  5 MB
> PCI:   Bus Dev VenId DevId Class Int
> In:    serial
> Out:   serial
> Err:   serial
> KGDB:  kgdb ready
> ready
> Net:   ppc_440x_eth0
> BEDBUG:ready
> => boot
> Waiting for PHY auto negotiation to complete.. done
> ENET Speed is 100 Mbps - FULL duplex connection
> Using ppc_440x_eth0 device
> TFTP from server 172.30.36.154; our IP address is 172.30.39.77
> Filename 'ocotea-vanassb'.
> Load address: 0x1000000
> Loading: T #################################################################
>          #################################################################
>          #################################################################
>          #################################################################
>          #################
> done
> Bytes transferred = 1415440 (159910 hex)
> Automatic boot of image at addr 0x01000000 ...
> ## Booting image at 01000000 ...
>    Image Name:   Linux-2.6.22
>    Created:      2007-07-18   6:53:56 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    1415376 Bytes =  1.3 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
>    Uncompressing Kernel Image ... OK
> Linux version 2.6.22 (vanassb@sabekorlnx05) (gcc version 3.4.3 (MontaVista
> 3.4.7
> IBM Ocotea port (MontaVista Software, Inc. <source@mvista.com>)
> Zone PFN ranges:
>   DMA             0 ->    65536
>   Normal      65536 ->    65536
> early_node_map[1] active PFN ranges
>     0:        0 ->    65536
> Built 1 zonelists.  Total pages: 65024
> Kernel command line: root=/dev/nfs
> nfsroot=172.30.36.154:/nfs-export/RFS_MVL4-00
> PID hash table entries: 1024 (order: 10, 4096 bytes)
> ------------------------
> | Locking API testsuite:
> ----------------------------------------------------------------------------
>                                  | spin |wlock |rlock |mutex | wsem | rsem |
>   --------------------------------------------------------------------------
>                      A-A deadlock:failed|failed|  ok  |failed|failed|failed|
>                  A-B-B-A deadlock:failed|failed|  ok  |failed|failed|failed|
>              A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|failed|
>              A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|failed|
>          A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
>          A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
>          A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
>                     double unlock:  ok  |  ok  |failed|  ok  |failed|failed|
>                   initialize held:failed|failed|failed|failed|failed|failed|
>                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
>   --------------------------------------------------------------------------
>               recursive read-lock:             |  ok  |             |failed|
>            recursive read-lock #2:             |  ok  |             |failed|
>             mixed read-write-lock:             |failed|             |failed|
>             mixed write-read-lock:             |failed|             |failed|
>   --------------------------------------------------------------------------
>      hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
>      soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
>      hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
>      soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
>        sirq-safe-A => hirqs-on/12:failed|failed|  ok  |
>        sirq-safe-A => hirqs-on/21:failed|failed|  ok  |
>          hard-safe-A + irqs-on/12:failed|failed|  ok  |
>          soft-safe-A + irqs-on/12:failed|failed|  ok  |
>          hard-safe-A + irqs-on/21:failed|failed|  ok  |
>          soft-safe-A + irqs-on/21:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
>     hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
>     soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
>       hard-irq lock-inversion/123:failed|failed|  ok  |
>       soft-irq lock-inversion/123:failed|failed|  ok  |
>       hard-irq lock-inversion/132:failed|failed|  ok  |
>       soft-irq lock-inversion/132:failed|failed|  ok  |
>       hard-irq lock-inversion/213:failed|failed|  ok  |
>       soft-irq lock-inversion/213:failed|failed|  ok  |
>       hard-irq lock-inversion/231:failed|failed|  ok  |
>       soft-irq lock-inversion/231:failed|failed|  ok  |
>       hard-irq lock-inversion/312:failed|failed|  ok  |
>       soft-irq lock-inversion/312:failed|failed|  ok  |
>       hard-irq lock-inversion/321:failed|failed|  ok  |
>       soft-irq lock-inversion/321:failed|failed|  ok  |
>       hard-irq read-recursion/123:  ok  |
>       soft-irq read-recursion/123:  ok  |
>       hard-irq read-recursion/132:  ok  |
>       soft-irq read-recursion/132:  ok  |
>       hard-irq read-recursion/213:  ok  |
>       soft-irq read-recursion/213:  ok  |
>       hard-irq read-recursion/231:  ok  |
>       soft-irq read-recursion/231:  ok  |
>       hard-irq read-recursion/312:  ok  |
>       soft-irq read-recursion/312:  ok  |
>       hard-irq read-recursion/321:  ok  |
>       soft-irq read-recursion/321:  ok  |
> --------------------------------------------------------
> 142 out of 218 testcases failed, as expected. |
> ----------------------------------------------------
> Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
> Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
> Memory: 256768k available (2088k kernel code, 816k data, 128k init, 0k highmem)
> Mount-cache hash table entries: 512
> NET: Registered protocol family 16
> PCI: Probing PCI hardware
> NET: Registered protocol family 2
> IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
> TCP established hash table entries: 8192 (order: 5, 163840 bytes)
> TCP bind hash table entries: 8192 (order: 5, 163840 bytes)
> TCP: Hash tables configured (established 8192 bind 8192)
> TCP reno registered
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> io scheduler noop registered
> io scheduler deadline registered (default)
> Serial: 8250/16550 driver $Revision: 1.90 $ 2 ports, IRQ sharing disabled
> serial8250: ttyS0 at MMIO 0x0 (irq = 0) is a 16550A
> serial8250: ttyS1 at MMIO 0x0 (irq = 1) is a 16550A
> RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
> loop: module loaded
> PPC 4xx OCP EMAC driver, version 3.54
> mal0: initialized, 4 TX channels, 4 RX channels
> zmii0: bridge in SMII mode
> eth0: emac0, MAC 00:04:ac:e3:28:8a
> eth0: found Generic MII PHY (0x01)
> eth1: emac1, MAC 00:00:00:00:00:00
> eth1: found Generic MII PHY (0x02)
> rgmii0: input 0 in RGMII mode
> eth2: emac2, MAC 00:00:00:00:00:00
> eth2: found CIS8201 Gigabit Ethernet PHY (0x10)
> rgmii0: input 1 in RGMII mode
> eth3: emac3, MAC 00:00:00:00:00:00
> eth3: found CIS8201 Gigabit Ethernet PHY (0x18)
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 50MHz system bus speed for PIO modes; override with idebus=xx
> i2c /dev entries driver
> IBM IIC driver v2.1
> ibm-iic0: using standard (100 kHz) mode
> ibm-iic1: using standard (100 kHz) mode
> Netfilter messages via NETLINK v0.30.
> TCP cubic registered
> NET: Registered protocol family 1
> NET: Registered protocol family 17
> eth0: link is down
> IP-Config: Complete:
>       device=eth0, addr=172.30.39.77, mask=255.255.252.0, gw=172.30.39.254,
>      host=ocotea, domain=, nis-domain=(none),
>      bootserver=172.30.36.154, rootserver=172.30.36.154, rootpath=
> Looking up port of RPC 100003/3 on 172.30.36.154
> eth0: link is up, 100 FDX, pause enabled
> Looking up port of RPC 100005/3 on 172.30.36.154
> VFS: Mounted root (nfs filesystem) readonly.
> Freeing unused kernel memory: 128k init
> Oops: kernel access of bad area, sig: 11 [#1]
> PREEMPT
> NIP: c004be40 LR: c017d9d8 CTR: c01822fc
> REGS: c02b1af0 TRAP: 0300   Not tainted  (2.6.22)
> MSR: 00029000 <EE,ME>  CR: 28f22b24  XER: 20000000
> DAR: 99750000, DSISR: 00000000
> TASK = c0296830[0] 'swapper' THREAD: c02b0000
> GPR00: c017d9d8 c02b1ba0 c0296830 99750000 c026cb38 000000f8 3b92a76c c02d73ec
> GPR08: 0000000c 99750004 00000001 000006a8 00000781 5c8071f0 0fff1200 00000000
> GPR16: 00000001 00000001 c02ae020 c02d0000 080103cf 00000001 000003cf c02b1be8
> GPR24: c01f2c1c c02b1c30 000000f8 c07d3510 000000f8 c0786998 c0786998 99750000
> NIP [c004be40] put_page+0x18/0x170
> LR [c017d9d8] skb_release_data+0x70/0xb4
> Call Trace:
> [c02b1ba0] [000000f8] 0xf8 (unreliable)
> [c02b1bc0] [c017d9d8] skb_release_data+0x70/0xb4
> [c02b1bd0] [c017d730] kfree_skbmem+0x18/0xdc
> [c02b1be0] [c01b0d3c] tcp_read_sock+0x188/0x1d8
> [c02b1c20] [c01f3134] xs_tcp_data_ready+0x70/0x94
> [c02b1c50] [c01b960c] tcp_rcv_established+0x4b4/0x758
> [c02b1c80] [c01c1274] tcp_v4_do_rcv+0x15c/0x44c
> [c02b1cc0] [c01c1efc] tcp_v4_rcv+0x998/0xa58
> [c02b1d10] [c01a3d48] ip_local_deliver+0x1f8/0x320
> [c02b1d40] [c01a4450] ip_rcv+0x298/0x598
> [c02b1d70] [c0185828] netif_receive_skb+0x2d0/0x334
> [c02b1da0] [c01583e4] emac_poll_rx+0x140/0x724
> [c02b1df0] [c0155c50] mal_poll+0xa8/0x26c
> [c02b1e30] [c0185a88] net_rx_action+0x88/0x15c
> [c02b1e60] [c001facc] __do_softirq+0x78/0xd4
> [c02b1e90] [c0006d50] do_softirq+0x54/0x5c
> [c02b1ea0] [c001fb9c] irq_exit+0x60/0x80
> [c02b1eb0] [c0006cac] do_IRQ+0x68/0xb8
> [c02b1ec0] [c000201c] ret_from_except+0x0/0x18
> [c02b1f80] [c0009eb4] cpu_idle+0xe8/0xf8
> [c02b1fa0] [c0205278] rest_init+0x74/0x88
> [c02b1fc0] [c02b2724] start_kernel+0x250/0x2b4
> [c02b1ff0] [c00001e8] skpinv+0x190/0x1cc
> Instruction dump:
> 80010014 38210010 7c0803a6 4e800020 8163000c 4bffffb0 7c0802a6 9421ffe0
> bfa10014 39230004 90010024 7c7f1b78 <80030000> 700a4000 4082013c 7c004828
> Kernel panic - not syncing: Aiee, killing interrupt handler!
> Rebooting in 180 seconds..

hm, it's hard to tell if this is a net problem, a driver problem or
an NFS problem or what.

