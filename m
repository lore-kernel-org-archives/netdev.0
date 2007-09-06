From: Alexandre Ghisoli <alexandre.ghisoli@ycom.ch>
Subject: PROBLEM: Oops with forcedeth and netkey in 2.6.21 and 22
Date: Fri, 07 Sep 2007 00:49:27 +0200
Message-ID: <1189118967.6728.21.camel@amd64-linux>
Reply-To: alexandre.ghisoli@ycom.ch
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-proxy-be-01.sunrise.ch ([194.158.229.48]:22114 "EHLO
	smtp-auth-be-02.sunrise.ch" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753659AbXIGHhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 03:37:16 -0400
Received: from [192.168.1.33] (adsl-84-226-137-189.adslplus.ch [84.226.137.189])
	by smtp-auth-be-02.sunrise.ch (8.13.1/8.13.5) with ESMTP id l86MoElN021285
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 00:50:14 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there, 

I cannot get my AMD64 working with forcedeth network chip and Netkey.

While recompiling kernel to get iptables and OpenSWAN working, I cannot
anymore boot my computer, it freeze on network setup.

After some reboots / recompile, I've traced the problem arround NetKEY.
If I enable it in the kernel, I'm getting oops.

Starting in single, I've been able to see errors comming because
dhcpclient process and af_packet module. If I dont load af_packet at
boot, i can setup manually an ip address. Unfortunaty, when lauching
gnome, my computer hang (probably some process tries to load
af_packets ?)

The NIC is on-board NIC on the MSI Neo4 Platinum motherboard (product
MS-7125)

I've tried thoses kernel version, same behavior :
 - 2.6.21.6
 - 2.6.22.1
 - 2.6.22.6


Here is the oops I got (dmesg captured) :

skb_under_panic: text:c02b089c len:14 put:14 head:f74e8410 data:f74e8402
tail:f74e8400 end:f74e8580 dev:<NULL>
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:111!
invalid opcode: 0000 [#1]
PREEMPT SMP
Modules linked in: af_packet usbhid sha256 sha1 hmac crypto_hash des
crypto_algapi af_key xfrm_user ohci_hcd parport_pc ehci_hcd usbcore
parport ohci1394 ieee1394 nvidia(P) floppy forcedeth sg
CPU:    1
EIP:    0060:[<c029f0c9>]    Tainted: P       VLI
EFLAGS: 00010292   (2.6.21.6 #2)
EIP is at skb_under_panic+0x59/0x60
eax: 00000072   ebx: f74e8410   ecx: f72a2000   edx: 00000000
esi: 00000000   edi: 00000800   ebp: 00000000   esp: f72a3d6c
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process dhcpcd (pid: 3723, ti=f72a2000 task=f76bd030 task.ti=f72a2000)
Stack: c0398bd0 c02b089c 0000000e 0000000e f74e8410 f74e8402 f74e8400
f74e8580
       c037d386 f74e8402 f7fa4c80 c02b08a1 f79b4000 f72a3f40 f79b4000
c215a900
       f7fa4c80 f8b95cca f72a3ecc 00000000 00000148 c016c455 f7a92600
0008cae0
Call Trace:
 [<c02b089c>] eth_header+0x10c/0x120
 [<c02b08a1>] eth_header+0x111/0x120
 [<f8b95cca>] packet_sendmsg+0x14a/0x260 [af_packet]
 [<c016c455>] link_path_walk+0x65/0xc0
 [<c0299dbe>] sock_sendmsg+0xce/0x100
 [<c0131180>] autoremove_wake_function+0x0/0x40
 [<c016d3d4>] path_lookup+0x14/0x20
 [<c02fdb10>] unix_find_other+0x30/0x1a0
 [<c029a193>] sys_sendto+0x133/0x180
 [<c029b1ce>] sys_socketcall+0x14e/0x280
 [<c0102c7e>] sysenter_past_esp+0x5f/0x85
 =======================
Code: 00 00 89 5c 24 14 8b 98 90 00 00 00 89 54 24 0c 89 5c 24 10 8b 40
60 89 4c 24 04 c7 04 24 d0 8b 39 c0 89 44 24 08 e8 57 f4 e7 ff <0f> 0b
eb fe 8d 76 00 56 53 bb 86 d3 37 c0 83 ec 24 8b 70 14 85
EIP: [<c029f0c9>] skb_under_panic+0x59/0x60 SS:ESP 0068:f72a3d6c

Here is my running environement :
Linux amd64-linux 2.6.21.6 #1 SMP PREEMPT Thu Sep 6 23:33:04 CEST 2007
i686 AMD Athlon(tm) 64 X2 Dual Core Processor 4200+ AuthenticAMD
GNU/Linux
 
Gnu C                  4.2.0
Gnu make               3.81
binutils               Binutils
util-linux             2.12r
mount                  2.12r
module-init-tools      3.2.2
e2fsprogs              1.40.2
reiserfsprogs          3.6.19
PPP                    2.4.4
Linux C Library        > libc.2.6
Dynamic linker (ldd)   2.6
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.13
Sh-utils               6.9
udev                   114

And my on-board NIC :
00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
        Subsystem: Micro-Star International Co., Ltd. Unknown device
7125
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0 (250ns min, 5000ns max)
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fe029000 (32-bit, non-prefetchable)
[size=4K]
        Region 1: I/O ports at b400 [size=8]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1
+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable+ DSel=0 DScale=0 PME-

Thanks for your help.

--Alexandre

