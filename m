From: Ray Lehtiniemi <rayl@mail.com>
Subject: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Sun, 5 Dec 2004 19:44:37 -0700
Message-ID: <20041206024437.GB7891@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi all

i'm trying to understand how to tune a pair of e1000 cards in
a server box.  the box is a dual xeon 3.06 with hyperthreading,
using the intel e7501 chipset, with both cards on hub interface
D.  the application involves small UDP packets, generally under
300 bytes. i need to maximize the number of packets per second
transferred between the two cards.

at the moment, i'm looking at the PCI bus in this box to see
what might be tweakable.  lspci output for the relevant parts is
attached below.  

could anyone give me an idea:

 - what kind of packets per second i could expect to achieve
   from this particular system (for small packets)

 - what parameters i can tweak at the PCI level (or any other
   level, for that matter...) to achieve that level of performance

for example, how could i get my e1000 cards to say '64bit+ 133MHz+'
to match the secondary side of the 82870P2 bridge?


thank you


-------------------------------------------------------------------------
lspci -t
-------------------------------------------------------------------------

-[00]-+-00.0
      +-00.1
      +-04.0-[01-03]--+-1c.0
      |               +-1d.0-[02]--+-01.0
      |               |            \-02.0
      |               +-1e.0
      |               \-1f.0-[03]--
      +-1d.0
      +-1d.1
      +-1d.2
      +-1e.0-[04]--+-03.0
      |            \-06.0
      +-1f.0
      +-1f.1
      \-1f.3


-------------------------------------------------------------------------
lspci -vv (selected items)
-------------------------------------------------------------------------

0000:00:00.0 Host bridge: Intel Corp. E7501 Memory Controller Hub (rev 01)
        Subsystem: Intel Corp. E7501 Memory Controller Hub
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Capabilities: [40] #09 [1105]

0000:00:04.0 PCI bridge: Intel Corp. E7000 Series Hub Interface D PCI-to-PCI Bridge (rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32
        Bus: primary=00, secondary=01, subordinate=03, sec-latency=0
        I/O behind bridge: 0000b000-0000bfff
        Memory behind bridge: f9000000-fbffffff
        BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-

0000:01:1c.0 PIC: Intel Corp. 82870P2 P64H2 I/OxAPIC (rev 04) (prog-if 20 [IO(X)-APIC])
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Region 0: Memory at fb000000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [50] PCI-X non-bridge device.
                Command: DPERE- ERO- RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-

0000:01:1d.0 PCI bridge: Intel Corp. 82870P2 P64H2 Hub PCI Bridge (rev 04) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32, cache line size 10
        Bus: primary=01, secondary=02, subordinate=02, sec-latency=64
        I/O behind bridge: 0000b000-0000bfff
        Memory behind bridge: f9000000-faffffff
        BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort+ >Reset- FastB2B-
        Capabilities: [50] PCI-X bridge device.
                Secondary Status: 64bit+, 133MHz+, SCD-, USC-, SCO-, SRD- Freq=3
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, SCO-, SRD-
                : Upstream: Capacity=0, Commitment Limit=0
                : Downstream: Capacity=0, Commitment Limit=0

0000:02:01.0 Ethernet controller: Intel Corp. 82544EI Gigabit Ethernet Controller (Copper) (rev 02)
        Subsystem: Intel Corp. PRO/1000 XT Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (63750ns min), cache line size 08
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at fa020000 (64-bit, non-prefetchable) [size=128K]
        Region 2: Memory at fa000000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at b000 [size=32]
        Expansion ROM at <unassigned> [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-      Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000

0000:02:02.0 Ethernet controller: Intel Corp. 82544EI Gigabit Ethernet Controller (Copper) (rev 02)
        Subsystem: Intel Corp. PRO/1000 XT Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (63750ns min), cache line size 08
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at fa040000 (64-bit, non-prefetchable) [size=128K]
        Region 2: Memory at fa060000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at b400 [size=32]
        Expansion ROM at <unassigned> [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-      Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000




-- 
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
