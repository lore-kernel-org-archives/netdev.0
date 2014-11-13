From: poma <pomidorabelisima@gmail.com>
Subject: Resume S4 - r8169 BROKEN
Date: Thu, 13 Nov 2014 10:50:50 +0100
Message-ID: <54647EFA.5020707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:58144 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074AbaKMJu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 04:50:56 -0500
Received: by mail-wg0-f45.google.com with SMTP id x12so16401655wgg.4
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 01:50:53 -0800 (PST)
Received: from localhost (iskon7113.duo.carnet.hr. [31.147.123.201])
        by mx.google.com with ESMTPSA id td9sm25015511wic.15.2014.11.13.01.50.51
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Nov 2014 01:50:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Resume S4 - r8169 RealTek RTL-8169 Gigabit Ethernet driver - BROKEN

Tested with:
  kernel-3.18.0-0.rc4.git0.2.fc22
    http://koji.fedoraproject.org/koji/buildinfo?buildID=592269
      Nov 11 2014
  &
  kernel-3.18.0-rc2.git-9dfa9a2-net-next+
    https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=9dfa9a2
      2014-11-13


# lspci -knn -s 03:00.0
03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 02)
	Subsystem: Gigabyte Technology Co., Ltd Motherboard [1458:e000]
	Kernel driver in use: r8169
	Kernel modules: r8169


# modprobe -v r8169
insmod /lib/modules/3.18.0-rc2.git-9dfa9a2-net-next+/kernel/drivers/net/mii.ko 
insmod /lib/modules/3.18.0-rc2.git-9dfa9a2-net-next+/kernel/drivers/net/ethernet/realtek/r8169.ko 


# dmesg
[  142.344223] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[  142.344229] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have ASPM control
[  142.344456] r8169 0000:03:00.0: irq 26 for MSI/MSI-X
[  142.344600] r8169 0000:03:00.0 eth1: RTL8168c/8111c at 0xffffc9000291a000, 00:12:34:56:78:30, XID 1c4000c0 IRQ 26
[  142.344602] r8169 0000:03:00.0 eth1: jumbo features [frames: 6128 bytes, tx checksumming: ko]
[  142.388933] r8169 0000:03:00.0 enp3s0: renamed from eth1
[  142.417502] r8169 0000:03:00.0 enp3s0: link down
[  142.417512] r8169 0000:03:00.0 enp3s0: link down
[  144.029918] r8169 0000:03:00.0 enp3s0: link up


# ifconfig enp3s0
enp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::212:34ff:fe56:7830  prefixlen 64  scopeid 0x20<link>
        ether 00:12:34:56:78:30  txqueuelen 1000  (Ethernet)
        RX packets 642  bytes 382970 (373.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 709  bytes 72634 (70.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


# ping kernel.org -c10
PING kernel.org (199.204.44.194) 56(84) bytes of data.
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=1 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=2 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=3 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=4 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=5 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=6 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=7 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=8 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=9 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=10 ttl=49 time=134 ms

--- kernel.org ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9011ms
rtt min/avg/max/mdev = 133.008/134.163/134.987/0.683 ms

~~~~~~~~~~~~~~~~~~~
# systemctl suspend
          & RESUME
          ~~~~~~~~

# dmesg
[  673.601499] PM: Syncing filesystems ... done.
[  673.793930] PM: Preparing system for mem sleep
[  673.961198] Freezing user space processes ... (elapsed 0.002 seconds) done.
[  673.963420] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[  673.964664] PM: Entering mem sleep
[  676.457146] PM: suspend of devices complete after 2492.103 msecs
[  676.457826] PM: late suspend of devices complete after 0.673 msecs
[  676.469303] PM: noirq suspend of devices complete after 11.469 msecs
[  676.469889] ACPI: Preparing to enter system sleep state S3
[  676.470890] PM: Saving platform NVS memory
[  676.479540] ACPI: Low-level resume complete
[  676.479613] PM: Restoring platform NVS memory
[  676.525167] ACPI: Waking up from system sleep state S3
[  676.590780] r8169 0000:03:00.0 enp3s0: link down
[  678.060741] r8169 0000:03:00.0 enp3s0: link up
[  679.604068] PM: resume of devices complete after 3066.534 msecs
[  679.604657] PM: Finishing wakeup.
[  679.604662] Restarting tasks ... done.


# ifconfig enp3s0
enp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::212:34ff:fe56:7830  prefixlen 64  scopeid 0x20<link>
        ether 00:12:34:56:78:30  txqueuelen 1000  (Ethernet)
        RX packets 782  bytes 464566 (453.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 860  bytes 86524 (84.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


# ping kernel.org -c10
PING kernel.org (199.204.44.194) 56(84) bytes of data.
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=1 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=2 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=3 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=4 ttl=49 time=132 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=5 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=6 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=7 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=8 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=9 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=10 ttl=49 time=134 ms

--- kernel.org ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9011ms
rtt min/avg/max/mdev = 132.798/133.770/134.919/0.682 ms

~~~~~~~~~~~~~~~~~~~~~
# systemctl hibernate
          & THAW
          ~~~~~~

# dmesg
[ 1187.902839] PM: Hibernation mode set to 'platform'
[ 1188.098296] PM: Syncing filesystems ... done.
[ 1188.545125] Freezing user space processes ... (elapsed 0.002 seconds) done.
[ 1188.548022] PM: Marking nosave pages: [mem 0x00000000-0x00000fff]
[ 1188.548031] PM: Marking nosave pages: [mem 0x0009e000-0x000fffff]
[ 1188.548042] PM: Marking nosave pages: [mem 0xcfef0000-0xffffffff]
[ 1188.549729] PM: Basic memory bitmaps created
[ 1188.549755] PM: Preallocating image memory... done (allocated 641929 pages)
[ 1189.133132] PM: Allocated 2567716 kbytes in 0.58 seconds (4427.09 MB/s)
[ 1189.133241] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[ 1191.867738] PM: freeze of devices complete after 2732.078 msecs
[ 1191.868597] PM: late freeze of devices complete after 0.855 msecs
[ 1191.869951] PM: noirq freeze of devices complete after 1.344 msecs
[ 1191.871294] ACPI: Preparing to enter system sleep state S4
[ 1191.871956] PM: Saving platform NVS memory
[ 1191.879106] PM: Creating hibernation image:
[ 1192.100544] PM: Need to copy 359761 pages
[ 1192.100558] PM: Normal pages needed: 359761 + 1024, available pages: 688358
[ 1191.880196] PM: Restoring platform NVS memory
[ 1191.925748] ACPI: Waking up from system sleep state S4
[ 1191.936325] PM: noirq restore of devices complete after 10.428 msecs
[ 1191.936796] PM: early restore of devices complete after 0.423 msecs
[ 1192.043225] r8169 0000:03:00.0 enp3s0: link down
[ 1192.689507] PM: restore of devices complete after 699.641 msecs
[ 1192.689835] PM: Image restored successfully.
[ 1192.689856] PM: Basic memory bitmaps freed
[ 1192.689860] Restarting tasks ... done.
[ 1193.672620] r8169 0000:03:00.0 enp3s0: link up


# ifconfig enp3s0
enp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::212:34ff:fe56:7830  prefixlen 64  scopeid 0x20<link>
        ether 00:12:34:56:78:30  txqueuelen 1000  (Ethernet)
        RX packets 794  bytes 465496 (454.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 939  bytes 90700 (88.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


# ping kernel.org -c10
ping: unknown host kernel.org

# ping 199.204.44.194 -c10
PING 199.204.44.194 (199.204.44.194) 56(84) bytes of data.
>From 192.168.2.2 icmp_seq=1 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=2 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=3 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=4 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=5 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=6 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=7 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=8 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=9 Destination Host Unreachable
>From 192.168.2.2 icmp_seq=10 Destination Host Unreachable

--- 199.204.44.194 ping statistics ---
10 packets transmitted, 0 received, +10 errors, 100% packet loss, time 9001ms
pipe 4

~~~~~~~~~~~~~~~~~~~~    ~~~~~~~~~~~~~~~~~
# modprobe -rv r8169 && modprobe -v r8169
rmmod r8169
rmmod mii
insmod /lib/modules/3.18.0-rc2.git-9dfa9a2-net-next+/kernel/drivers/net/mii.ko 
insmod /lib/modules/3.18.0-rc2.git-9dfa9a2-net-next+/kernel/drivers/net/ethernet/realtek/r8169.ko 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# dmesg
[ 1566.163904] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[ 1566.163932] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have ASPM control
[ 1566.164443] r8169 0000:03:00.0: irq 26 for MSI/MSI-X
[ 1566.164997] r8169 0000:03:00.0 eth1: RTL8168c/8111c at 0xffffc900027d0000, 00:12:34:56:78:30, XID 1c4000c0 IRQ 26
[ 1566.165007] r8169 0000:03:00.0 eth1: jumbo features [frames: 6128 bytes, tx checksumming: ko]
[ 1566.383002] r8169 0000:03:00.0 enp3s0: renamed from eth1
[ 1566.401190] r8169 0000:03:00.0 enp3s0: link down
[ 1567.909282] r8169 0000:03:00.0 enp3s0: link up


# ifconfig enp3s0
enp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::212:34ff:fe56:7830  prefixlen 64  scopeid 0x20<link>
        ether 00:12:34:56:78:30  txqueuelen 1000  (Ethernet)
        RX packets 59  bytes 14200 (13.8 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 77  bytes 7441 (7.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


# ping kernel.org -c10
PING kernel.org (199.204.44.194) 56(84) bytes of data.
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=1 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=2 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=3 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=4 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=5 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=6 ttl=49 time=132 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=7 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=8 ttl=49 time=134 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=9 ttl=49 time=133 ms
64 bytes from yul-korg-pub.kernel.org (199.204.44.194): icmp_seq=10 ttl=49 time=133 ms

--- kernel.org ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9012ms
rtt min/avg/max/mdev = 132.657/133.636/134.708/0.728 ms


poma
