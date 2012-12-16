From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: BUG: unable to handle kernel NULL pointer dereference + panic on
 3.2.11 (with various networking pointers, on Dell r720xd)
Date: Sun, 16 Dec 2012 14:56:16 +0200
Message-ID: <50CDC4F0.6010206@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

a server running 3.2.11 just crashed with rather lengthy (~3 MB) dump:

http://www.virtall.com/files/temp/3.2.11-panic.txt


Any pointers, info if it was fixed or not, appreciated.
The server is Dell r720xd, 128 GB RAM, plenty of disks and around 1 Gbit/s constant traffic.


# lspci
00:00.0 Host bridge: Intel Corporation Sandy Bridge DMI2 (rev 07)
00:01.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 1a (rev 07)
00:01.1 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 1b (rev 07)
00:02.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 2a (rev 07)
00:02.2 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 2c (rev 07)
00:03.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 3a in PCI Express Mode (rev 07)
00:05.0 System peripheral: Intel Corporation Sandy Bridge Address Map, VTd_Misc, System Management (rev 07)
00:05.2 System peripheral: Intel Corporation Sandy Bridge Control Status and Global Errors (rev 07)
00:11.0 PCI bridge: Intel Corporation Patsburg PCI Express Virtual Root Port (rev 05)
00:16.0 Communication controller: Intel Corporation X79 series chipset HECI Controller #2 (rev 05)
00:16.1 Communication controller: Intel Corporation X79 series chipset IDE-r Controller (rev 05)
00:1a.0 USB controller: Intel Corporation X79 series chipset USB2 Enhanced Host Controller #2 (rev 05)
00:1c.0 PCI bridge: Intel Corporation X79 series chipset PCI Express Root Port 1 (rev b5)
00:1c.7 PCI bridge: Intel Corporation X79 series chipset PCI Express Root Port 8 (rev b5)
00:1d.0 USB controller: Intel Corporation X79 series chipset USB2 Enhanced Host Controller #1 (rev 05)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a5)
00:1f.0 ISA bridge: Intel Corporation X79 series chipset LPC Controller (rev 05)
01:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720 Gigabit Ethernet PCIe
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720 Gigabit Ethernet PCIe
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720 Gigabit Ethernet PCIe
02:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720 Gigabit Ethernet PCIe
03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS 2208 [Thunderbolt] (rev 01)
08:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
09:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
09:01.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe Switch [PS]
0a:00.0 PCI bridge: Renesas Technology Corp. SH7757 PCIe-PCI Bridge [PPB]
0b:00.0 VGA compatible controller: Matrox Graphics, Inc. G200eR2
3f:08.0 System peripheral: Intel Corporation Sandy Bridge QPI Link 0 (rev 07)
3f:09.0 System peripheral: Intel Corporation Sandy Bridge QPI Link 1 (rev 07)
3f:0a.0 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 0 (rev 07)
3f:0a.1 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 1 (rev 07)
3f:0a.2 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 2 (rev 07)
3f:0a.3 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 3 (rev 07)
3f:0b.0 System peripheral: Intel Corporation Sandy Bridge Interrupt Control Registers (rev 07)
3f:0b.3 System peripheral: Intel Corporation Sandy Bridge Semaphore and Scratchpad Configuration Registers (rev 07)
3f:0c.0 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0c.1 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0c.2 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0c.3 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0c.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller System Address Decoder 0 (rev 07)
3f:0c.7 System peripheral: Intel Corporation Sandy Bridge System Address Decoder (rev 07)
3f:0d.0 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0d.1 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0d.2 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0d.3 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
3f:0d.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller System Address Decoder 1 (rev 07)
3f:0e.0 System peripheral: Intel Corporation Sandy Bridge Processor Home Agent (rev 07)
3f:0e.1 Performance counters: Intel Corporation Sandy Bridge Processor Home Agent Performance Monitoring (rev 07)
3f:0f.0 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Registers (rev 07)
3f:0f.1 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller RAS Registers (rev 07)
3f:0f.2 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 0 (rev 07)
3f:0f.3 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 1 (rev 07)
3f:0f.4 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 2 (rev 07)
3f:0f.5 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 3 (rev 07)
3f:0f.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 4 (rev 07)
3f:10.0 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 0 (rev 07)
3f:10.1 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 1 (rev 07)
3f:10.2 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 0 (rev 07)
3f:10.3 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 1 (rev 07)
3f:10.4 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 2 (rev 07)
3f:10.5 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 3 (rev 07)
3f:10.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 2 (rev 07)
3f:10.7 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 3 (rev 07)
3f:11.0 System peripheral: Intel Corporation Sandy Bridge DDRIO (rev 07)
3f:13.0 System peripheral: Intel Corporation Sandy Bridge R2PCIe (rev 07)
3f:13.1 Performance counters: Intel Corporation Sandy Bridge Ring to PCI Express Performance Monitor (rev 07)
3f:13.4 Performance counters: Intel Corporation Sandy Bridge QuickPath Interconnect Agent Ring Registers (rev 07)
3f:13.5 Performance counters: Intel Corporation Sandy Bridge Ring to QuickPath Interconnect Link 0 Performance Monitor (rev 07)
3f:13.6 System peripheral: Intel Corporation Sandy Bridge Ring to QuickPath Interconnect Link 1 Performance Monitor (rev 07)
40:01.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 1a (rev 07)
40:02.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 2a (rev 07)
40:03.0 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 3a in PCI Express Mode (rev 07)
40:03.2 PCI bridge: Intel Corporation Sandy Bridge IIO PCI Express Root Port 3c (rev 07)
40:05.0 System peripheral: Intel Corporation Sandy Bridge Address Map, VTd_Misc, System Management (rev 07)
40:05.2 System peripheral: Intel Corporation Sandy Bridge Control Status and Global Errors (rev 07)
7f:08.0 System peripheral: Intel Corporation Sandy Bridge QPI Link 0 (rev 07)
7f:09.0 System peripheral: Intel Corporation Sandy Bridge QPI Link 1 (rev 07)
7f:0a.0 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 0 (rev 07)
7f:0a.1 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 1 (rev 07)
7f:0a.2 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 2 (rev 07)
7f:0a.3 System peripheral: Intel Corporation Sandy Bridge Power Control Unit 3 (rev 07)
7f:0b.0 System peripheral: Intel Corporation Sandy Bridge Interrupt Control Registers (rev 07)
7f:0b.3 System peripheral: Intel Corporation Sandy Bridge Semaphore and Scratchpad Configuration Registers (rev 07)
7f:0c.0 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0c.1 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0c.2 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0c.3 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0c.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller System Address Decoder 0 (rev 07)
7f:0c.7 System peripheral: Intel Corporation Sandy Bridge System Address Decoder (rev 07)
7f:0d.0 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0d.1 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0d.2 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0d.3 System peripheral: Intel Corporation Sandy Bridge Unicast Register 0 (rev 07)
7f:0d.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller System Address Decoder 1 (rev 07)
7f:0e.0 System peripheral: Intel Corporation Sandy Bridge Processor Home Agent (rev 07)
7f:0e.1 Performance counters: Intel Corporation Sandy Bridge Processor Home Agent Performance Monitoring (rev 07)
7f:0f.0 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Registers (rev 07)
7f:0f.1 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller RAS Registers (rev 07)
7f:0f.2 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 0 (rev 07)
7f:0f.3 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 1 (rev 07)
7f:0f.4 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 2 (rev 07)
7f:0f.5 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 3 (rev 07)
7f:0f.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Target Address Decoder 4 (rev 07)
7f:10.0 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 0 (rev 07)
7f:10.1 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 1 (rev 07)
7f:10.2 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 0 (rev 07)
7f:10.3 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 1 (rev 07)
7f:10.4 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 2 (rev 07)
7f:10.5 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller Channel 0-3 Thermal Control 3 (rev 07)
7f:10.6 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 2 (rev 07)
7f:10.7 System peripheral: Intel Corporation Sandy Bridge Integrated Memory Controller ERROR Registers 3 (rev 07)
7f:11.0 System peripheral: Intel Corporation Sandy Bridge DDRIO (rev 07)
7f:13.0 System peripheral: Intel Corporation Sandy Bridge R2PCIe (rev 07)
7f:13.1 Performance counters: Intel Corporation Sandy Bridge Ring to PCI Express Performance Monitor (rev 07)
7f:13.4 Performance counters: Intel Corporation Sandy Bridge QuickPath Interconnect Agent Ring Registers (rev 07)
7f:13.5 Performance counters: Intel Corporation Sandy Bridge Ring to QuickPath Interconnect Link 0 Performance Monitor (rev 07)
7f:13.6 System peripheral: Intel Corporation Sandy Bridge Ring to QuickPath Interconnect Link 1 Performance Monitor (rev 07)



-- 
Tomasz Chmielewski
