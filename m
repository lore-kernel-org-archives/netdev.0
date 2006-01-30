From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: [BUG] 8139too fails for ip autoconfig and nfsroot
Date: Mon, 30 Jan 2006 20:59:49 +0100
Message-ID: <43DE7035.1040806@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964933AbWA3T7q@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a number of systems equipped with:

0000:05:05.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8139/8139C/8139C+ (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RT8139
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max)
        Interrupt: pin A routed to IRQ 177
        Region 0: I/O ports at d000 [size=1027M]
        Region 1: Memory at d0320000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at 00020000 [disabled]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

Those cards have PXE boot roms.

There are no problems in normal operation, but something is totaly wrong 
when I
try to use those cards for network booting:

I compiled a kernel for nfsroot and dhcp ip autoconfiguration, 
configured the server and tried
to boot. Well, booting memtest and booting msdos works perfectly fine. 
Loading the kernel
is also no problem, but at the point of ip autoconfiguration (ip=dhcp) 
the kernel loops sending
DHCPDISCOVER packets. Those packets arrive at the server, and the server 
responds appropiately.
ic_bootp_recv() never gets called (checked by a printk). I suspected a 
server malconfiguration,
but found none. Skipping ip autoconfig is no solution, the kernel then 
fails trying rpc lookup.

Then I tried to netboot another system with the same kernel + via rhine 
driver, same server
config. Voila, dhcp ip autoconfig and rpc port lookup is not a problem 
on this system.

During my search for a solution I tried some recent kernels, the oldest 
2.6.14. All fail with 8139too.

Any ideas?

cu,
 Knut
