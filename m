From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Transmit timeout with E1000
Date: Tue, 10 Jan 2006 16:12:54 +0100
Message-ID: <20060110151254.GA24273@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: e1000-devel@lists.sf.net
Content-Disposition: inline
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hi,

I have lots of transmit timeouts with an Intel E1000 card during large
TCP transmissions (remotely viewing a 3000x2000 jpeg image using XV is
an excellent way to trigger it). This is what I get in linux-2.6.8.1:

Jan 10 15:24:41 zurix kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jan 10 15:24:41 zurix kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
Jan 10 15:24:46 zurix kernel: nfs: server abra2 not responding, still trying
Jan 10 15:24:46 zurix kernel: nfs: server abra2 OK

And this is with linux-2.6.15:

Jan 10 06:53:27 zurix kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jan 10 06:53:27 zurix kernel:   TDH                  <b0>
Jan 10 06:53:27 zurix kernel:   TDT                  <b0>
Jan 10 06:53:27 zurix kernel:   next_to_use          <b0>
Jan 10 06:53:27 zurix kernel:   next_to_clean        <c3>
Jan 10 06:53:27 zurix kernel: buffer_info[next_to_clean]
Jan 10 06:53:27 zurix kernel:   dma                  <e938a5e>
Jan 10 06:53:27 zurix kernel:   time_stamp           <872de93>
Jan 10 06:53:27 zurix kernel:   next_to_watch        <c3>
Jan 10 06:53:27 zurix kernel:   jiffies              <872e086>
Jan 10 06:53:27 zurix kernel:   next_to_watch.status <0>
Jan 10 06:53:29 zurix kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jan 10 06:53:29 zurix kernel:   TDH                  <b0>
Jan 10 06:53:29 zurix kernel:   TDT                  <b0>
Jan 10 06:53:29 zurix kernel:   next_to_use          <b0>
Jan 10 06:53:29 zurix kernel:   next_to_clean        <c3>
Jan 10 06:53:29 zurix kernel: buffer_info[next_to_clean]
Jan 10 06:53:29 zurix kernel:   dma                  <e938a5e>
Jan 10 06:53:29 zurix kernel:   time_stamp           <872de93>
Jan 10 06:53:29 zurix kernel:   next_to_watch        <c3>
Jan 10 06:53:29 zurix kernel:   jiffies              <872e27a>
Jan 10 06:53:29 zurix kernel:   next_to_watch.status <0>
Jan 10 06:53:31 zurix kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
Jan 10 06:53:31 zurix kernel:   TDH                  <b0>
Jan 10 06:53:31 zurix kernel:   TDT                  <b0>
Jan 10 06:53:31 zurix kernel:   next_to_use          <b0>
Jan 10 06:53:31 zurix kernel:   next_to_clean        <c3>
Jan 10 06:53:31 zurix kernel: buffer_info[next_to_clean]
Jan 10 06:53:31 zurix kernel:   dma                  <e938a5e>
Jan 10 06:53:31 zurix kernel:   time_stamp           <872de93>
Jan 10 06:53:31 zurix kernel:   next_to_watch        <c3>
Jan 10 06:53:31 zurix kernel:   jiffies              <872e46e>
Jan 10 06:53:31 zurix kernel:   next_to_watch.status <0>
Jan 10 06:53:32 zurix kernel: nfs: server abra2 not responding, still trying
Jan 10 06:53:33 zurix kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jan 10 06:53:36 zurix kernel: e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
Jan 10 06:53:37 zurix kernel: nfs: server abra2 OK

The system is a an AMD Athlon XP 2000+ running at 1.666 GHz with a VIA
KT400 chipset (Asrock K7VT4APro).

Here's the relevant output from lspci:

0000:00:0b.0 Ethernet controller: Intel Corporation 82541PI Gigabit
Ethernet Controller (rev 05)
        Subsystem: Intel Corporation: Unknown device 1376
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (63750ns min), Cache Line Size: 0x08 (32 bytes)
        Interrupt: pin A routed to IRQ 19
        Region 0: Memory at dffc0000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at dffa0000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at d400 [size=64]
        Expansion ROM at fffe0000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-
00: 86 80 7c 10 17 00 30 02 05 00 00 02 08 20 00 00
10: 00 00 fc df 00 00 fa df 01 d4 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 76 13
30: 00 00 fe ff dc 00 00 00 00 00 00 00 0c 01 ff 00

Loaded modules (with 2.6.8.1): nfsd exportfs sd_mod sg lp sr_mod
autofs4 nfs lockd sunrpc ide_cd cdrom floppy parport_pc parport
8250_pnp 8250 serial_core snd_via82xx snd_ac97_codec snd_pcm_oss
snd_mixer_oss snd_pcm snd_timer snd_page_alloc gameport snd_mpu401_uart
snd_rawmidi snd_seq_device snd soundcore joydev evdev ehci_hcd usbhid
uhci_hcd usbcore sata_via libata e1000 reiserfs mga via_agp agpgart .

So far I have replaced the NIC, the motherboard, the power supply, RAM,
network cable, and gigE switch, but to no avail. I've tried three
different kernels (2.6.8.1, 2.6.11-ac7, and 2.6.15) but the problem
remains. I've been stress testing the system by continuously compiling
kernels (over NFS), but after 288 runs there hasn't been a single error
so I guess the CPU and RAM are OK. The amount of transmit timeouts is
less with linux-2.6.8.1, so for the moment I keep running that version.

We have about 15 other machines using the Intel E1000, but I haven't
seen these kind of problems on any of the other machines. I have run
out of ideas, so I hope somebody knows how to solve this. If you need
more information, just let me know.


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
