From: Erik Hensema <erik@hensema.net>
Subject: IPv6 autoconfiguration slow on 2.5.66-mm3
Date: Tue, 15 Apr 2003 10:09:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415080948.GB1192@hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

My 2.5.66-mm3 system is slow to receive an autoconfigured IPv6 address.
Today it took about 7 minutes of uptime before my interface was configured.

This was before:
| bender:~ # ip -6 a
| 1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
|     inet6 ::1/128 scope host
| 3: eth0: <BROADCAST,MULTICAST,NOTRAILERS,UP> mtu 1500 qdisc pfifo_fast qlen 100
|     inet6 fe80::202:44ff:fe69:60f5/64 scope link

And this after:
| bender:~ # ip -6 a
| 1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
|     inet6 ::1/128 scope host
| 3: eth0: <BROADCAST,MULTICAST,NOTRAILERS,UP> mtu 1500 qdisc pfifo_fast qlen 100
|     inet6 fe80::202:44ff:fe69:60f5/64 scope link
|     inet6 2001:888:10a1:0:202:44ff:fe69:60f5/64 scope global dynamic
|        valid_lft 2591995sec preferred_lft 604795sec
| bender:~ # uptime
|  10:01:14  up 7 min,  5 users,  load average: 0.02, 0.14, 0.09

In dmesg:

| 8139too Fast Ethernet driver 0.9.26
| eth0: RealTek RTL8139 Fast Ethernet at 0xe0b4ee00, 00:02:44:69:60:f5, IRQ 16
| eth0:  Identified 8139 chip type 'RTL-8139C'
| eth0: Setting 100mbps full-duplex based on auto-negotiated partner ability 45e1.
| eth0: no IPv6 routers present

My router is running zebra-0.92a-238 (SuSE 8.0). Autoconfiguration works
fine and instantly on 2.4 kernels.

It *could* be IO-APIC related, I haven't tested that yet.

-- 
Erik Hensema (erik@hensema.net)
