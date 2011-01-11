From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: panic in tg3 driver
Date: Mon, 10 Jan 2011 18:00:55 -0800
Message-ID: <20110111020055.GA25351@mcarlson.broadcom.com>
References: <4D2334B5.1060408@earthlink.net>
 <4D2A371A.40103@earthlink.net>
 <20110110192216.GA23741@mcarlson.broadcom.com>
 <4D2B6652.7040607@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stephen Clark" <sclark46@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4296 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755434Ab1AKCBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 21:01:06 -0500
In-Reply-To: <4D2B6652.7040607@earthlink.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 12:04:34PM -0800, Stephen Clark wrote:
> On 01/10/2011 02:22 PM, Matt Carlson wrote:
> > On Sun, Jan 09, 2011 at 02:30:50PM -0800, Stephen Clark wrote:
> >    
> >> On 01/04/2011 09:54 AM, Stephen Clark wrote:
> >>      
> >>> Hello,
> >>>
> >>>
> >>> The hardware is an Acrosser AR-M0898B micro box.
> >>>   lspci
> >>> 00:00.0 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro
> >>> Host Bridge
> >>> 00:00.1 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro
> >>> Host Bridge
> >>> 00:00.2 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro
> >>> Host Bridge
> >>> 00:00.3 Host bridge: VIA Technologies, Inc. PT890 Host Bridge
> >>> 00:00.4 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro
> >>> Host Bridge
> >>> 00:00.7 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro
> >>> Host Bridge
> >>> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8237/VX700 PCI Bridge
> >>> 00:0f.0 IDE interface: VIA Technologies, Inc. VT8251 Serial ATA
> >>> Controller (rev
> >>> 20)
> >>> 00:0f.1 IDE interface: VIA Technologies, Inc.
> >>> VT82C586A/B/VT82C686/A/B/VT823x/A/
> >>> C PIPC Bus Master IDE (rev 07)
> >>> 00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> >>> Controller
> >>>   (rev 91)
> >>> 00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> >>> Controller
> >>>   (rev 91)
> >>> 00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> >>> Controller
> >>>   (rev 91)
> >>> 00:10.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> >>> Controller
> >>>   (rev 91)
> >>> 00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 90)
> >>> 00:11.0 ISA bridge: VIA Technologies, Inc. VT8251 PCI to ISA Bridge
> >>> 00:11.7 Host bridge: VIA Technologies, Inc. VT8251 Ultra VLINK Controller
> >>> 00:13.0 Host bridge: VIA Technologies, Inc. VT8251 Host Bridge
> >>> 00:13.1 PCI bridge: VIA Technologies, Inc. VT8251 PCI to PCI Bridge
> >>> 02:08.0 Ethernet controller: Broadcom Corporation BCM4401 100Base-T
> >>> (rev 02)
> >>> 02:09.0 Ethernet controller: Broadcom Corporation BCM4401 100Base-T
> >>> (rev 02)
> >>> 80:00.0 PCI bridge: VIA Technologies, Inc. VT8251 PCIE Root Port
> >>> 80:00.1 PCI bridge: VIA Technologies, Inc. VT8251 PCIE Root Port
> >>> 81:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5906M
> >>> Fast Ethernet
> >>>   PCI Express (rev 02)
> >>> 82:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5906M
> >>> Fast Ethernet
> >>>   PCI Express (rev 02)
> >>>
> >>> Kernel 2.6.36-2.el5.elrepo on an i686
> >>>
> >>> When I try to ifconfig either of the BCM5906M ports the system panics.
> >>>
> >>> Ideas, fixes ?
> >>>
> >>> [root@Z1010 ~]# modprobe tg3
> >>> [root@Z1010 ~]# ifconfig eth2 2.2.2.2/24
> >>> ------------[ cut here ]------------
> >>> kernel BUG at drivers/net/tg3.c:4365!
> >>> invalid opcode: 0000 [#1] PREEMPT SMP
> >>> last sysfs file: /sys/class/net/eth3/address
> >>> Modules linked in: tg3 xt_tcpudp ipt_LOG xt_limit xt_state
> >>> iptable_mangle af_ke]
> >>>
> >>> Pid: 20303, comm: kworker/0:2 Not tainted 2.6.36-2.el5.elrepo #1
> >>> CN700-8251/
> >>> EIP: 0060:[<e1c62f19>] EFLAGS: 00010202 CPU: 0
> >>> EIP is at tg3_tx_recover+0x1e/0x53 [tg3]
> >>> EAX: deece4c0 EBX: dfa9c000 ECX: deece4c0 EDX: ffffffff
> >>> ESI: deece4c0 EDI: deece500 EBP: c1801f38 ESP: c1801f30
> >>>   DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> >>> Process kworker/0:2 (pid: 20303, ti=c1801000 task=df0105d0
> >>> task.ti=dee62000)
> >>> Stack:
> >>>   dfa9c000 00000000 c1801f6c e1c630be c1801f6c deece4c0 00000840 00000000
> >>> <0>  df251cc0 00000005 00000000 df979800 deece500 deece4c0 00000040
> >>> c1801f94
> >>> <0>  e1c661e5 00000000 00000040 c1801f88 e09df1d2 00000000 deece500
> >>> dfab4000
> >>> Call Trace:
> >>>   [<e1c630be>] ? tg3_tx+0x157/0x1a2 [tg3]
> >>>   [<e1c661e5>] ? tg3_poll_work+0x2b/0x10b [tg3]
> >>>   [<e09df1d2>] ? ssb_write32+0x11/0x14 [b44]
> >>>   [<e1c662f9>] ? tg3_poll+0x34/0x9a [tg3]
> >>>   [<c0674058>] ? net_rx_action+0x7e/0x11c
> >>>   [<c04409c9>] ? __do_softirq+0x85/0x10c
> >>>   [<c0440944>] ? __do_softirq+0x0/0x10c
> >>> <IRQ>
> >>>   [<c04404ef>] ? _local_bh_enable_ip+0x68/0x87
> >>>   [<c044051b>] ? local_bh_enable_ip+0xd/0xf
> >>>   [<c046593b>] ? __raw_spin_unlock_bh+0x1c/0x1e
> >>>   [<c06fa4f2>] ? _raw_spin_unlock_bh+0xd/0xf
> >>>   [<e1c6281f>] ? spin_unlock_bh+0xd/0xf [tg3]
> >>>   [<e1c62cbe>] ? tg3_full_unlock+0x10/0x12 [tg3]
> >>>   [<e1c664c7>] ? tg3_reset_task+0xd7/0xe3 [tg3]
> >>>   [<c044ec37>] ? process_one_work+0x10b/0x1bc
> >>>   [<e1c663f0>] ? tg3_reset_task+0x0/0xe3 [tg3]
> >>>   [<c044fd41>] ? worker_thread+0x77/0xf9
> >>>   [<c0453048>] ? kthread+0x60/0x65
> >>>   [<c044fcca>] ? worker_thread+0x0/0xf9
> >>>   [<c0452fe8>] ? kthread+0x0/0x65
> >>>   [<c040337e>] ? kernel_thread_helper+0x6/0x10
> >>> Code: f0 e8 88 ff ff ff 8d 65 f8 5b 5e 5d c3 55 89 e5 56 53 0f 1f 44
> >>> 00 00 f6 8
> >>> EIP: [<e1c62f19>] tg3_tx_recover+0x1e/0x53 [tg3] SS:ESP 0068:c1801f30
> >>> ---[ end trace 82381e9b93e397ad ]---
> >>> Kernel panic - not syncing: Fatal exception in interrupt
> >>> Pid: 20303, comm: kworker/0:2 Tainted: G      D
> >>> 2.6.36-2.el5.elrepo #1
> >>> Call Trace:
> >>>   [<c043b3cd>] panic+0x62/0x15d
> >>>   [<c06fb7d1>] oops_end+0x99/0xa8
> >>>   [<e1c62f19>] ? tg3_tx_recover+0x1e/0x53 [tg3]
> >>>   [<c0405a62>] die+0x58/0x5e
> >>>
> >>> Thanks,
> >>> Steve
> >>>
> >>>        
> >> Additonal info I compiled the latest kernel 2.6.37-rc8+ and still have the problem.
> >> Also boot with noapic I see this in the dmesg log and interrupts are increasing
> >> like crazy:
> >> tg3.c:v3.115 (October 14, 2010)
> >> tg3 0000:81:00.0: PCI INT A ->  Link[LNKA] ->  GSI 10 (level, low) ->  IRQ 10
> >> tg3 0000:81:00.0: setting latency timer to 64
> >> tg3 0000:81:00.0: PCI: Disallowing DAC for device
> >> tg3 0000:81:00.0: eth2: Tigon3 [partno(BCM95906) rev c002] (PCI Express) MAC add
> >> ress 00:02:b6:36:d1:39
> >> tg3 0000:81:00.0: eth2: attached PHY is 5906 (10/100Base-TX Ethernet) (WireSpeed
> >> [0])
> >> tg3 0000:81:00.0: eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> >> tg3 0000:81:00.0: eth2: dma_rwctrl[76180000] dma_mask[32-bit]
> >> tg3 0000:82:00.0: PCI INT A ->  Link[LNKA] ->  GSI 10 (level, low) ->  IRQ 10
> >> tg3 0000:82:00.0: setting latency timer to 64
> >> tg3 0000:82:00.0: PCI: Disallowing DAC for device
> >> tg3 0000:82:00.0: eth3: Tigon3 [partno(BCM95906) rev c002] (PCI Express) MAC add
> >> ress 00:02:b6:36:d1:3a
> >> tg3 0000:82:00.0: eth3: attached PHY is 5906 (10/100Base-TX Ethernet) (WireSpeed
> >> [0])
> >> tg3 0000:82:00.0: eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> >> tg3 0000:82:00.0: eth3: dma_rwctrl[76180000] dma_mask[32-bit]
> >> tg3 0000:81:00.0: irq 40 for MSI/MSI-X
> >> tg3 0000:81:00.0: eth2: No interrupt was generated using MSI. Switching to INTx
> >> mode. Please report this failure to the PCI maintainer and include system chipse
> >> t information
> >> ADDRCONF(NETDEV_UP): eth2: link is not ready
> >> [root@Z1010 ~]# cat /proc/interrupts
> >>              CPU0
> >>     0:        162    XT-PIC-XT-PIC    timer
> >>     1:          2    XT-PIC-XT-PIC    i8042
> >>     2:          0    XT-PIC-XT-PIC    cascade
> >>     3:          1    XT-PIC-XT-PIC
> >>     4:       4863    XT-PIC-XT-PIC    serial
> >>     6:          2    XT-PIC-XT-PIC    floppy
> >>     7:          5    XT-PIC-XT-PIC    ehci_hcd:usb1, uhci_hcd:usb3
> >>     8:          0    XT-PIC-XT-PIC    rtc0
> >>     9:          0    XT-PIC-XT-PIC    acpi
> >>    10:    2334234    XT-PIC-XT-PIC    uhci_hcd:usb2, eth0, eth2
> >>
> >> [root@Z1010 ~]# cat /proc/interrupts |grep eth2
> >>    10:   18388914    XT-PIC-XT-PIC    uhci_hcd:usb2, eth0, eth2
> >> [root@Z1010 ~]# cat /proc/interrupts |grep eth2
> >>    10:   18901627    XT-PIC-XT-PIC    uhci_hcd:usb2, eth0, eth2
> >>
> >> -- 
> >>
> >> "They that give up essential liberty to obtain temporary safety,
> >> deserve neither liberty nor safety."  (Ben Franklin)
> >>
> >> "The course of history shows that as a government grows, liberty
> >> decreases."  (Thomas Jefferson)
> >>      
> > I think drivers/net/tg3.c:4365 is at the line that reads
> > "spin_lock(&tp->lock);" in tg3_tx_recover.  Can you verify?
> >
> >    
> 
> 
>          tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &phy2);
> 
> in static void tg3_serdes_parallel_detect(struct tg3 *tp)
> 
> The driver version is:
> #define DRV_MODULE_NAME        "tg3"
> #define TG3_MAJ_NUM            3
> #define TG3_MIN_NUM            115


That doesn't look right.  The line number I quoted came from the kernel
panic output from 2.6.36-2.el5.elrepo.  I'm guessing you quoted me the
sources from the tg3.c file in 2.6.37-rc8+.  If you don't have the
2.6.36-2.el5.elrepo sources readily available, can you give me the line
the kernel panic specifies from the tg3.c file from your 2.6.37-rc8+
sources?

It looks like there are a lot of devices on IRQ 10.  Does the interrupt
count drop if you bring down eth0 (which I'm guessing is the b44 device)?

Can you tell me if you saw the following message in the syslogs?

"The system may be re-ordering memory-mapped I/O cycles to the network
 device, attempting to recover.  Please report the problem to the driver
 maintainer and include system chipset information."

