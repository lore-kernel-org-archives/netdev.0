From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: e1000 lockup with port io type reset
Date: Fri, 27 Jun 2003 08:44:29 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0306270843300.12261@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(forwarded due to missing Cc)

Hi Scott,
	The following card causes a hard lockup when we do a controller 
reset using port io instead of mmio. Switching to mmio controller reset 
causes it to function as expected (The patch illustrates this). Side note, 
is it possible to get access to errata sheets for these cards?

Thank you,
	Zwane

00:08.0 Ethernet controller: Intel Corp. 82544GC Gigabit Ethernet Controller (Copper) (rev 02)
	Subsystem: Intel Corp. PRO/1000 T Desktop Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (63750ns min), cache line size 08
	Interrupt: pin A routed to IRQ 3
	Region 0: Memory at f9800000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f9000000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at a800 [size=32]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

Index: linux-2.5/drivers/net/e1000/e1000_hw.c
===================================================================
RCS file: /home/cvs/linux-2.5/drivers/net/e1000/e1000_hw.c,v
retrieving revision 1.16
diff -u -p -B -r1.16 e1000_hw.c
--- linux-2.5/drivers/net/e1000/e1000_hw.c	26 May 2003 00:31:31 -0000	1.16
+++ linux-2.5/drivers/net/e1000/e1000_hw.c	27 Jun 2003 06:25:01 -0000
@@ -259,7 +259,7 @@ e1000_reset_hw(struct e1000_hw *hw)
 	msec_delay(5);
     }
 
-    if(hw->mac_type > e1000_82543)
+    if(hw->mac_type > e1000_82544)
         E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_RST));
     else
         E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));

-- 
function.linuxpower.ca
