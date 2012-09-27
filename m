From: Nolwenn <donolwenn@gmail.com>
Subject: Possible bug with r8169 driver
Date: Thu, 27 Sep 2012 14:24:47 +0000
Message-ID: <2197741.c8FeV4Xbis@bureau>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50133 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab2I0OYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 10:24:51 -0400
Received: by eaac13 with SMTP id c13so648271eaa.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 07:24:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm on Archlinux (kernel 3.5.4), I need to set eth0 to promiscuous to get a 
stable IPv6 connectivity. My internet access provider is Free (France) and 
IPv6 is enable on the box. 
If eth0 is not set to promiscuous, I need to intercep packets with 
"tcpdump -nvvv ip6" to get an IPv6 connectivity and it's lost, a few later, 
when interception is stopped. 

Regards

Nolwenn

PS : sorry for my bad english

Some information on hardware and settings

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI 
Express Gigabit Ethernet controller (rev 09)
        Subsystem: ASUSTeK Computer Inc. Device 8505
        Flags: bus master, fast devsel, latency 0, IRQ 44
        I/O ports at e000 [size=256]
        Memory at f0004000 (64-bit, prefetchable) [size=4K]
        Memory at f0000000 (64-bit, prefetchable) [size=16K]
        Capabilities: <access denied>
        Kernel driver in use: r8169


sysctl.conf (nothing in /etc/sysctl.d directory)
=======

# Configuration file for runtime kernel parameters.
# See sysctl.conf(5) for more information.

# Have the CD-ROM close when you use it, and open when you are done.
#dev.cdrom.autoclose = 1
#dev.cdrom.autoeject = 1

# Protection from the SYN flood attack.
net.ipv4.tcp_syncookies = 1

# See evil packets in your logs.
#net.ipv4.conf.all.log_martians = 1

# Never accept redirects or source routes (these are only useful for routers).
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_source_route = 0

# Disable packet forwarding.
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Tweak the port range used for outgoing connections.
#net.ipv4.ip_local_port_range = 32768 61000

# Tweak those values to alter disk syncing and swap behavior.
#vm.vfs_cache_pressure = 100
#vm.laptop_mode = 0
#vm.swappiness = 60

# Tweak how the flow of kernel messages is throttled.
#kernel.printk_ratelimit_burst = 10
#kernel.printk_ratelimit = 5

# Reboot 600 seconds after kernel panic or oops.
#kernel.panic_on_oops = 1
#kernel.panic = 600

# Disable SysRq key to avoid console security issues.
kernel.sysrq = 0



% dmesg | grep r8169 

[    1.810423] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.810548] r8169 0000:03:00.0: irq 44 for MSI/MSI-X
[    1.810671] r8169 0000:03:00.0: eth0: RTL8168f/8111f at 0xffffc900057ae000, 
30:85:a9:ee:43:fa, XID 08000800 IRQ 44
[    1.810672] r8169 0000:03:00.0: eth0: jumbo features [frames: 9200 bytes, 
tx checksumming: ko]
[    3.061527] r8169 0000:03:00.0: eth0: link down
[    3.062343] r8169 0000:03:00.0: eth0: link down
[    4.690703] r8169 0000:03:00.0: eth0: link up

% ip addr 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast state UP qlen 1000
    link/ether 30:85:a9:ee:43:fa brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.11/24 brd 192.168.0.255 scope global eth0
    inet6 XXXX:XXXX:XXXX:2720:3285:a9ff:feee:43fa/64 scope global dynamic 
       valid_lft 85897sec preferred_lft 85897sec
    inet6 fe80::3285:a9ff:feee:43fa/64 scope link 
       valid_lft forever preferred_lft forever
