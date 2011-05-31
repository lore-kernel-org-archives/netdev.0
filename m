From: WeipingPan <panweiping3@gmail.com>
Subject: netxen_nic: unregister_netdevice error
Date: Tue, 31 May 2011 14:15:24 +0800
Message-ID: <4DE4877C.1070704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:58871 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1EaGOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 02:14:46 -0400
Received: by qyg14 with SMTP id 14so2216044qyg.19
        for <netdev@vger.kernel.org>; Mon, 30 May 2011 23:14:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

When test bonding broadcast mode I met a problem.
modprobe -r bonding will fail after I ping broadcast address.

I find that the problem only shows up when I use netxen_nic driver.
When use ixgbe and bn2x2 driver, no problem occurs.

I use RHEL 6.2, kernel 2.6.32-131.0.15.el6.i686,
Can anybody confirm this bug using 2.6.39 or upstream ?

many thanks
Weiping Pan


The test script is followed.

#test script start
#!/bin/bash

NETWORK_CARD0=eth1
NETWORK_CARD1=eth2


function broadcast_test()
{
     modprobe bonding mode=broadcast miimon=100
     ifconfig bond0 192.168.8.2 netmask 255.255.255.0 up
     ifconfig $NETWORK_CARD0 down
     ifconfig $NETWORK_CARD1 down
     echo +$NETWORK_CARD0 > /sys/class/net/bond0/bonding/slaves
     echo +$NETWORK_CARD1 > /sys/class/net/bond0/bonding/slaves
     ping 192.168.8.255 -b -c 10
     modprobe -r bonding
}

# main
echo 0 >/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
modprobe -r bonding

for i in `seq 1 10`
do
     echo    "*******************"
     echo     "***iteration$i*****"
     echo -e "*******************\n\n"
     broadcast_test
done
#test script end


Some information is followed.
[root@hp-magnycours-01 ~]# uname -a
Linux hp-magnycours-01.rhts.eng.bos.redhat.com 2.6.32-131.0.15.el6.i686 
#1 SMP Tue May 10 15:42:28 EDT 2011 i686 i686 i386 GNU/Linux

[root@hp-magnycours-01 ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 6.1 (Santiago)

[root@hp-magnycours-01 ~]# lspci |grep Ethernet
04:00.0 Ethernet controller: NetXen Incorporated NX3031 Multifunction 
1/10-Gigabit Server Adapter (rev 42)
04:00.1 Ethernet controller: NetXen Incorporated NX3031 Multifunction 
1/10-Gigabit Server Adapter (rev 42)
04:00.2 Ethernet controller: NetXen Incorporated NX3031 Multifunction 
1/10-Gigabit Server Adapter (rev 42)
04:00.3 Ethernet controller: NetXen Incorporated NX3031 Multifunction 
1/10-Gigabit Server Adapter (rev 42)

[root@hp-magnycours-01 ~]# lsmod |grep net
netxen_nic             83405  0

[root@hp-magnycours-01 ~]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 1C:C1:DE:EE:28:F0
           inet addr:10.16.64.212  Bcast:10.16.71.255  Mask:255.255.248.0
           inet6 addr: fec0:0:a10:4000:1ec1:deff:feee:28f0/64 Scope:Site
           inet6 addr: fe80::1ec1:deff:feee:28f0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:13417 errors:0 dropped:0 overruns:0 frame:0
           TX packets:713 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1110663 (1.0 MiB)  TX bytes:90272 (88.1 KiB)
           Interrupt:93

eth1      Link encap:Ethernet  HWaddr 1C:C1:DE:EE:28:F1
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:97

eth2      Link encap:Ethernet  HWaddr 1C:C1:DE:EE:28:F2
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:101

eth3      Link encap:Ethernet  HWaddr 1C:C1:DE:EE:28:F3
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:105

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:18 errors:0 dropped:0 overruns:0 frame:0
           TX packets:18 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:10557 (10.3 KiB)  TX bytes:10557 (10.3 KiB)


[root@hp-magnycours-01 ~]# ./test_bonding_broadcast.sh |tee log
*******************
***iteration1*****
*******************


WARNING: pinging broadcast address
PING 192.168.8.255 (192.168.8.255) 56(84) bytes of data.
64 bytes from 192.168.8.2: icmp_seq=1 ttl=64 time=0.041 ms
64 bytes from 192.168.8.2: icmp_seq=2 ttl=64 time=0.029 ms
64 bytes from 192.168.8.2: icmp_seq=3 ttl=64 time=0.027 ms
64 bytes from 192.168.8.2: icmp_seq=4 ttl=64 time=0.026 ms
64 bytes from 192.168.8.2: icmp_seq=5 ttl=64 time=0.030 ms
64 bytes from 192.168.8.2: icmp_seq=6 ttl=64 time=0.024 ms
64 bytes from 192.168.8.2: icmp_seq=7 ttl=64 time=0.024 ms
64 bytes from 192.168.8.2: icmp_seq=8 ttl=64 time=0.023 ms
64 bytes from 192.168.8.2: icmp_seq=9 ttl=64 time=0.024 ms
64 bytes from 192.168.8.2: icmp_seq=10 ttl=64 time=0.023 ms

--- 192.168.8.255 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9000ms
rtt min/avg/max/mdev = 0.023/0.027/0.041/0.005 ms

Message from syslogd@hp-magnycours-01 at May 25 04:07:22 ...
  kernel:unregister_netdevice: waiting for bond0 to become free. Usage 
count = 1

Message from syslogd@hp-magnycours-01 at May 25 04:07:33 ...
  kernel:unregister_netdevice: waiting for bond0 to become free. Usage 
count = 1


[root@hp-magnycours-01 ~]# dmesg
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
bonding: MII link monitoring set to 100 ms
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: Adding slave eth1.
bonding: bond0: enslaving eth1 as an active interface with a down link.
netxen_nic: eth1 NIC Link is up
bonding: bond0: Adding slave eth2.
bonding: bond0: enslaving eth2 as an active interface with a down link.
netxen_nic: eth2 NIC Link is up
bonding: bond0: link status definitely up for interface eth1.
bonding: bond0: link status definitely up for interface eth2.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
bond0: IPv6 duplicate address fe80::1ec1:deff:feee:28f1 detected!
bonding: bond0: released all slaves
unregister_netdevice: waiting for bond0 to become free. Usage count = 1
unregister_netdevice: waiting for bond0 to become free. Usage count = 1
unregister_netdevice: waiting for bond0 to become free. Usage count = 1
unregister_netdevice: waiting for bond0 to become free. Usage count = 1

