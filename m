From: Jim Lieb <jlieb@panasas.com>
Subject: Mellanox mlx4_en update
Date: Fri, 26 Aug 2011 17:09:09 -0700
Message-ID: <201108261709.10119.jlieb@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44399 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab1H0AJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 20:09:15 -0400
Received: from seabiscuit.panasas.com (seabisbuit.panasas.com [172.17.132.204] (may be forged))
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id p7R09D97021948
	for <netdev@vger.kernel.org>; Fri, 26 Aug 2011 20:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having trouble getting the mlx4_en driver to work on 3.0.1 kernels.  On 
the advice of Yevgeny, I have pulled patches from net-next and applied them to 
a 3.0.1 stable tree which compiles and runs just fine except for the driver.  
What I know so far:

* The driver in the mlnx_en-1.5.6.tgz tarball from the Mellanox download site 
works just fine with Fedora 12/RHEL6 and earlier kernels.

* Mainline and stable + patches don't on 3.0.1.  See commands and logs below.

* A diff between the two (~15k lines) shows significant differences (mlx4_en is a 
newer version, 1.5.6)

* udev seems to want to install mlx4_core alone but removing and re-installing 
via modprobe of mlx4_en does the loading properly but the driver doesn't init 
properly as shown in the logs.

See the end of the log for a git log short of the patches on top of 3.0.1.

post-boot, the driver had not fully loaded so I removed the only module that 
did load.  I did not show the boot time dmesg but it is identical to the first 
part in the modprobe install log below.

The base install is Fedora 12 with updates on an x86_64 Westmere class server.  
Everything minus 10Ge worked for extensive internal testing.

Am I missing patches?  Might the firmware be out of date?  Note that it works 
w/ F12|RHEL[4-6].

If I can get working patches/firmware/??? I can repackage kernel RPMs so our 
lab folks can deploy this.

Thanks

Jim
Please CC me on the reply.

[root@ca-twin-22a-boot ~]# modprobe -r mlx4_core
[root@ca-twin-22a-boot ~]# cat /proc/modules |grep mlx
[root@ca-twin-22a-boot ~]# tail /var/log/messages
Aug 25 16:13:18 ca-twin-22a-boot sudo:    jlieb : TTY=pts/0 ; 
PWD=/net/nfs.panwest.panasas.com/home/jlieb ; USER=root ; COMMAND=/bin/bash
Aug 25 16:13:56 ca-twin-22a-boot kernel: [  219.388210] mlx4_core 
0000:08:00.0: PCI INT A disabled
Aug 25 16:13:56 ca-twin-22a-boot kernel: [  219.402558] mlx4_core 
0000:0a:00.0: PCI INT A disabled


[root@ca-twin-22a-boot ~]# modprobe mlx4_en
Aug 25 16:15:17 ca-twin-22a-boot kernel: [  300.481764] mlx4_core: Mellanox 
ConnectX core driver v1.0 (July 14, 2011)
Aug 25 16:15:17 ca-twin-22a-boot kernel: [  300.481769] mlx4_core: 
Initializing 0000:0a:00.0
Aug 25 16:15:17 ca-twin-22a-boot kernel: [  300.481789] mlx4_core 
0000:0a:00.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
Aug 25 16:15:19 ca-twin-22a-boot kernel: [  302.511615] mlx4_core 
0000:0a:00.0: Sense command failed for port: 1
Aug 25 16:15:19 ca-twin-22a-boot kernel: [  302.511856] mlx4_core: 
Initializing 0000:08:00.0
Aug 25 16:15:19 ca-twin-22a-boot kernel: [  302.511874] mlx4_core 
0000:08:00.0: PCI INT A -> GSI 30 (level, low) -> IRQ 30
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.045626] mlx4_core 
0000:08:00.0: Sense command failed for port: 1
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.045829] mlx4_core 
0000:08:00.0: Sense command failed for port: 2
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.104652] mlx4_en: Mellanox 
ConnectX HCA Ethernet driver v1.5.4.1 (March 2011)
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.105401] mlx4_en 0000:0a:00.0: 
UDP RSS is not supported on this device.
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.105784] mlx4_en 0000:08:00.0: 
UDP RSS is not supported on this device.
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.105838] mlx4_en 0000:08:00.0: 
Activating port:1
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.107174] mlx4_en: 0000:08:00.0: 
Port 1: Using 8 TX rings
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.107177] mlx4_en: 0000:08:00.0: 
Port 1: Using 16 RX rings
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.107319] mlx4_en: 0000:08:00.0: 
Port 1: Initializing port
Aug 25 16:15:21 ca-twin-22a-boot kernel: [  305.129594] udev: renamed network 
interface eth2 to eth3
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.594246] mlx4_en 0000:08:00.0: 
Activating port:2
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.953213] mlx4_en: eth3: Failed 
to allocate RSS indirection QP
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.954608] mlx4_en: eth3: Failed 
configuring rss steering
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.988594] mlx4_en: eth3: Failed 
starting port:1
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.989008] mlx4_en: 0000:08:00.0: 
Port 2: Using 8 TX rings
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.989012] mlx4_en: 0000:08:00.0: 
Port 2: Using 16 RX rings
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  305.989107] mlx4_en: 0000:08:00.0: 
Port 2: Initializing port
Aug 25 16:15:22 ca-twin-22a-boot kernel: [  306.022225] udev: renamed network 
interface eth2 to eth4


[root@ca-twin-22a-boot ~]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr E0:CB:4E:64:EA:89  
          inet addr:10.6.2.143  Bcast:10.6.2.255  Mask:255.255.255.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:16 Memory:fbce0000-fbd00000 

eth1      Link encap:Ethernet  HWaddr E0:CB:4E:64:EA:88  
          inet addr:10.6.1.143  Bcast:10.6.1.255  Mask:255.255.255.0
          inet6 addr: fe80::e2cb:4eff:fe64:ea88/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2066 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1558 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:560875 (547.7 KiB)  TX bytes:160892 (157.1 KiB)
          Interrupt:17 Memory:fbbe0000-fbc00000 

eth3      Link encap:Ethernet  HWaddr 00:02:C9:08:14:B6  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

eth4      Link encap:Ethernet  HWaddr 00:02:C9:08:14:B7  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:82 errors:0 dropped:0 overruns:0 frame:0
          TX packets:82 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:5500 (5.3 KiB)  TX bytes:5500 (5.3 KiB)

Scripts etc. in the fedora install:

[root@ca-twin-22a-boot network-scripts]# less ifcfg-eth3
# Please read /usr/share/doc/initscripts-*/sysconfig.txt
# for the documentation of these parameters.
GATEWAY=10.6.2.254
DNS1=172.17.132.60
DEVICE=eth3
BOOTPROTO=static
NETMASK=255.255.255.0
DNS2=172.17.132.29
TYPE=Ethernet
HWADDR=00:02:c9:08:14:b6
IPADDR=10.6.2.143
[root@ca-twin-22a-boot network-scripts]# host ca-twin-22a
ca-twin-22a.calab.panasas.com has address 10.6.2.143

restart the network

[root@ca-twin-22a-boot network-scripts]# service network restart
Shutting down interface eth0:  [  OK  ]
Shutting down interface eth1:  [  OK  ]
Shutting down loopback interface:  [  OK  ]
Bringing up loopback interface:  [  OK  ]
Bringing up interface eth0:  [  OK  ]
Bringing up interface eth1:  [  OK  ]
Bringing up interface eth3:  RTNETLINK answers: Bad file descriptor
Failed to bring up eth3.
[FAILED]

What the log shows during the restart:

Aug 25 16:17:26 ca-twin-22a-boot ntpd[2586]: Deleting interface #2 eth1, 
fe80::e2cb:4eff:fe64:ea88#123, interface stats: received=0, sent=0, dropped=0, 
active_time=273 secs
Aug 25 16:17:26 ca-twin-22a-boot ntpd[2586]: Deleting interface #5 eth0, 
10.6.2.143#123, interface stats: received=0, sent=0, dropped=0, 
active_time=273 secs
Aug 25 16:17:26 ca-twin-22a-boot ntpd[2586]: Deleting interface #6 eth1, 
10.6.1.143#123, interface stats: received=14, sent=14, dropped=0, 
active_time=273 secs
Aug 25 16:17:30 ca-twin-22a-boot avahi-daemon[2237]: Joining mDNS multicast 
group on interface eth0.IPv4 with address 10.6.2.143.
Aug 25 16:17:30 ca-twin-22a-boot avahi-daemon[2237]: New relevant interface 
eth0.IPv4 for mDNS.
Aug 25 16:17:30 ca-twin-22a-boot avahi-daemon[2237]: Registering new address 
record for 10.6.2.143 on eth0.IPv4.
Aug 25 16:17:30 ca-twin-22a-boot kernel: [  433.835452] ADDRCONF(NETDEV_UP): 
eth1: link is not ready
Aug 25 16:17:31 ca-twin-22a-boot ntpd[2586]: Listening on interface #7 eth0, 
10.6.2.143#123 Enabled
Aug 25 16:17:33 ca-twin-22a-boot kernel: [  436.917985] e1000e: eth1 NIC Link 
is Up 1000 Mbps Full Duplex, Flow Control: None
Aug 25 16:17:33 ca-twin-22a-boot kernel: [  436.919503] 
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Aug 25 16:17:35 ca-twin-22a-boot avahi-daemon[2237]: Registering new address 
record for fe80::e2cb:4eff:fe64:ea88 on eth1.*.
Aug 25 16:17:35 ca-twin-22a-boot avahi-daemon[2237]: Joining mDNS multicast 
group on interface eth1.IPv4 with address 10.6.1.143.
Aug 25 16:17:35 ca-twin-22a-boot avahi-daemon[2237]: New relevant interface 
eth1.IPv4 for mDNS.
Aug 25 16:17:35 ca-twin-22a-boot avahi-daemon[2237]: Registering new address 
record for 10.6.1.143 on eth1.IPv4.
Aug 25 16:17:35 ca-twin-22a-boot kernel: [  438.989438] mlx4_core 
0000:08:00.0: Failed to bring QP to state: 1 with error: -9
Aug 25 16:17:35 ca-twin-22a-boot kernel: [  438.990609] mlx4_en: eth3: Failed 
configuring rss steering
Aug 25 16:17:35 ca-twin-22a-boot kernel: [  439.026160] mlx4_en: eth3: Failed 
starting port:1
Aug 25 16:17:37 ca-twin-22a-boot ntpd[2586]: Listening on interface #8 eth1, 
fe80::e2cb:4eff:fe64:ea88#123 Enabled
Aug 25 16:17:37 ca-twin-22a-boot ntpd[2586]: Listening on interface #9 eth1, 
10.6.1.143#123 Enabled


git short log...

commit 31a5037e908bf73ac8c185ebd58727ed4af50785
Author: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

    mlx4: decreasing ref count when removing mac

commit 2c0ff8f3327ec1fcf4d184ea49281559955ffa59
Author: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

    mlx4: Fixing Ethernet unicast packet steering

commit d540b5c19da7e3e3fb17dcf508fe4674d915bb76
Author: Dotan Barak <dotanb@dev.mellanox.co.il>

    mlx4_core: Bump the driver version to 1.0

commit f2a0b4681c54bf7915e3ce65f1496eef9792fe00
Author: Jiri Pirko <jpirko@redhat.com>

    mlx4: do vlan cleanup

commit 9a3d46b2b017fface2355d150fb5cbf798066dd0
Author: Or Gerlitz <ogerlitz@mellanox.com>

    mlx4_core: Add network flow counters

commit ac7af6feb51a5d5243e306b7ab1ef89436aa1756
Author: Or Gerlitz <ogerlitz@mellanox.com>

    mlx4_core: Read extended capabilities into the flags field

commit 878184cd92ee22314f489392698972f8167ccd5d
Author: Or Gerlitz <ogerlitz@mellanox.com>

    mlx4_core: Extend capability flags to 64 bits

commit 348a8184aaad001bf85d7be4ae5d9bd4a176aae3
Author: Jon Mason <jdmason@kudzu.us>

    mlx4: remove unnecessary read of PCI_CAP_ID_EXP

commit c27c320827959efd1caf2f89c7991bffe5051d13
Author: Sergei Shtylyov <sshtylyov@ru.mvista.com>

    mlx4: use pci_dev->revision

commit e2074fa29c96b799dc9db0880c7bb6a850b77220
Author: Joe Perches <joe@perches.com>

    drivers/net: Remove casts of void *

commit 94ed5b4788a7cdbe68bc7cb8516972cbebdc8274
Author: Greg Kroah-Hartman <gregkh@suse.de>

    Linux 3.0.1


-- 
Jim Lieb
Linux Systems Engineer
Panasas Inc.
