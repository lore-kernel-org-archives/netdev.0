From: Dirk <biecie547@gmail.com>
Subject: Slow connection with RTL8168b/8111b
Date: Wed, 21 Feb 2007 16:44:07 +0100
Message-ID: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:43845 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbXBUPoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 10:44:09 -0500
Received: by wr-out-0506.google.com with SMTP id i31so2388165wra
        for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 07:44:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,


I'm experiencing very slow and fluctuating networkspeeds with my
onboard Realtek network card with certain applications.



Situation description:
Host A is my new file server and has 1 physical network interface
(Onboard RTL8168b/8111b nic) with 3 vlans defined (Internet, Internal
network, Wireless network) The hardware itself is an Asus P5B
mainboard, Intel D805 Cpu, 2 Gig ram. The operating system is Debian
Sarge.

Host B is a Windows XP desktop pc (Internal Network vlan)

Host C is my older fileserver and also runs linux (P4C800 mainboard
with Intel CSA gigabit nic). It only has an IP address on the Internal
network vlan. The operating system is Debian Sarge

The connection between the hosts is via a Dell Powerconnect 2708
Gigabit switch. Each host has a gigabit connection.



Problem description:
I have configured a samba network share on Host A (Version
3.0.14a-Debian) that is readable from the Internal network. However,
when host B or C try to copy or stream something from it, the
connection is really slow (>40 minutes to copy 700Mbyte). Copying
files with netcat or scp works as expected (>20Mbytes/sec).



Solutions tried:

1. I googled a bit and read similar reports about slow connections
with samba with the onboard Realtek nic of some asus mainboards (P5B
series)... but no samba configuration was found that obtained 'normal'
speeds.

2. I disabled the onboard nic on host A and installed an Intel E1000
PCI network card. No other changes have been made whatsoever. Problem
solved...the obtained samba network speed was normal (>20Mbytes/sec).
This makes me think it is a nic driver or hardware problem.

3. This is rather strange, but I hope a driver developer knows the reason:
I can get the normal networkspeeds with samba if the Realtek nic
receives/generates lots of packets. When I do on host B a 'ping -fq
hostA' (=pingflooding host A), the samba network speed increases to
normal speeds instantly (>20Mbyte/sec). As soon as I stop the
floodping, it's again slow speed. This is repeatable at any time. This
makes me think it is a pure software problem.

4. There are no network packet errors on host A (ifconfig eth0) or on
the Dell switch. I also tried every combination of rx/tx checksumming,
scatted gather, TSO but no difference. The original Realtek provided
driver (r1000, version 1.05) also has thesame performance problem (I
unloaded r8169 module, loaded r1000). I haven't tried the r8169 driver
yet with no NAPI enabled. Is there a way to enable/disable NAPI
without reloading the nic module?



Does someone have a clue about this problem? I can provide more
details or perform some tests if needed...


Kind regards,
Dirk





Some more information:

The used driver is the one present in a vanilla 2.6.20 kernel (NAPI
and VLAN options are enabled for the r8169 module):
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded

up:/# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off

up:/# ethtool -i eth0
driver: r8169
version: 2.2LK-NAPI
firmware-version:
bus-info: 0000:02:00.0

up:/# ethtool -S eth0
NIC statistics:
     tx_packets: 1412342391
     rx_packets: 1381266427
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1377779529
     broadcast: 3486883
     multicast: 3486898
     tx_aborted: 0
     tx_underrun: 0

up:/# lspci -vvv
0000:02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.:
Unknown device 8168 (rev 01)
        Subsystem: Asustek Computer, Inc.: Unknown device 81aa
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
                   Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
                   <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 0x20 (128 bytes)
        Interrupt: pin A routed to IRQ 17
        Region 0: I/O ports at 9800 [size=256]
        Region 2: Memory at fe9ff000 (64-bit, non-prefetchable) [size=4K]
        Expansion ROM at fe9c0000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
                          PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [48] Vital Product Data
        Capabilities: [50] Message Signalled Interrupts: 64bit+
Queue=0/1 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [60] #10 [0001]
        Capabilities: [84] #09 [014c]
