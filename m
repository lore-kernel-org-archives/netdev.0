From: Jiri Slaby <jirislaby@gmail.com>
Subject: 3c59x regression (transmission stop)
Date: Wed, 14 Mar 2007 13:33:32 +0100
Message-ID: <45F7EB9C.3070208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vortex@scyld.com
To: Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161228AbXCNMdm@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I have a problem with 3c59x network driver. After some time (now it happened 
after 6 days of uptime) the card stops transmitting packets. Interrupt 
counter increments, the card recieves and trasmits some buffers, but the 
more time, the less packets are trasmitted and in the end it stops 
trasmitting at all. I don't know how to debug this, rmmod and modprobe of 
the module back helps to solve this for some time.

What kind of info should I post and how to track this nasty thing down? 
Note, that this is server and hence things like bisecting is no-go for me.

# lspci -vvxs 00:0e
00:0e.0 Ethernet controller: 3Com Corporation 3c905B 100BaseTX [Cyclone] 
(rev 64)
         Subsystem: 3Com Corporation 3C905B Fast Etherlink XL 10/100
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (2500ns min, 2500ns max), Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 10
         Region 0: I/O ports at a800 [size=128]
         Region 1: Memory at f5000000 (32-bit, non-prefetchable) [size=128]
         [virtual] Expansion ROM at 30000000 [disabled] [size=128K]
         Capabilities: [dc] Power Management version 1
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1+,D2+,D3hot+,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: b7 10 55 90 17 00 10 02 64 00 00 02 08 20 00 00
10: 01 a8 00 00 00 00 00 f5 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 b7 10 55 90
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 0a 0a

# cat /proc/interrupts
            CPU0
   0:  524969030    XT-PIC-XT        timer
   1:       2270    XT-PIC-XT        i8042
   2:          0    XT-PIC-XT        cascade
   5:       1357    XT-PIC-XT        uhci_hcd:usb1, uhci_hcd:usb2, uhci_hcd:usb3
   6:          5    XT-PIC-XT        floppy
   7:         78    XT-PIC-XT        parport0
   8:          1    XT-PIC-XT        rtc
   9:          0    XT-PIC-XT        acpi
  10:   55418579    XT-PIC-XT        CMI8738-MC6, eth0
  11:   31568244    XT-PIC-XT        nvidia
  12:      12934    XT-PIC-XT        i8042
  14:    1946936    XT-PIC-XT        ide0
  15:    1293985    XT-PIC-XT        ide1
NMI:          0
ERR:          0

I know, that I have disabled APIC, I noted it yesterday and rebuilt the 
kernel with the APIC support, but still didn't reboot. If this is required 
I'll do so, but before that, there was running smp kernel and that kind of 
hangs appeared too.

There is nothing significant in dmesg, 2.6.17-rc5 was fine, so this is 
definitely a regression.

thanks,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz
e-mail: jirislaby gmail com, gpg pubkey fingerprint:
B674 9967 0407 CE62 ACC8  22A0 32CC 55C3 39D4 7A7E
