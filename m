From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Why my NIC shows NUMA -1?
Date: Wed, 11 Nov 2015 14:41:00 -0800
Message-ID: <CAK3+h2wTdCVHLpwoKF93aGeKd2MTtgMK2cNstw94a=Fv_94iGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33302 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbbKKWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:41:03 -0500
Received: by lbbkw15 with SMTP id kw15so25173157lbb.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:41:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Sorry I am not sure if this is the right list to ask this question,
please direct me to the correct one. thanks!

I am using Intel 82599 on Dell PowerEdge R710 which should support
NUMA node, the box is running ubuntu 14.01.1 LTS , I am wondering why I
get NUMA socket -1.

in BIOS, the memory "Node Interleaving" is
disabled by default and  I am using DPDK and DPDK sees my NIC NUMA -1,
but i guess it is
not related to DPDK since the sysfs  shows NUMA -1,  any clue?

 # uname -a
Linux pktgen 3.13.0-32-generic #57-Ubuntu SMP Tue Jul 15 03:51:08 UTC
2014 x86_64 x86_64 x86_64 GNU/Linux


EAL: Master lcore 0 is ready (tid=79b78900;cpuset=[0])
EAL: lcore 8 is ready (tid=f2deb700;cpuset=[8])
EAL: lcore 15 is ready (tid=ef5e4700;cpuset=[15])
EAL: lcore 5 is ready (tid=f45ee700;cpuset=[5])
EAL: lcore 2 is ready (tid=f5df1700;cpuset=[2])
EAL: lcore 10 is ready (tid=f1de9700;cpuset=[10])
EAL: lcore 6 is ready (tid=f3ded700;cpuset=[6])
EAL: lcore 7 is ready (tid=f35ec700;cpuset=[7])
EAL: lcore 11 is ready (tid=f15e8700;cpuset=[11])
EAL: lcore 1 is ready (tid=f65f2700;cpuset=[1])
EAL: lcore 13 is ready (tid=f05e6700;cpuset=[13])
EAL: lcore 4 is ready (tid=f4def700;cpuset=[4])
EAL: lcore 9 is ready (tid=f25ea700;cpuset=[9])
EAL: lcore 3 is ready (tid=f55f0700;cpuset=[3])
EAL: lcore 12 is ready (tid=f0de7700;cpuset=[12])
EAL: lcore 14 is ready (tid=efde5700;cpuset=[14])
EAL: PCI device 0000:04:00.0 on NUMA socket -1 <========
EAL:   probe driver: 8086:10fb rte_ixgbe_pmd
EAL:   Not managed by a supported kernel driver, skipped
EAL: PCI device 0000:04:00.1 on NUMA socket -1 <==============
EAL:   probe driver: 8086:10fb rte_ixgbe_pmd
EAL:   PCI memory mapped at 0x7feb77c00000
EAL:   PCI memory mapped at 0x7feb77c80000
PMD: eth_ixgbe_dev_init(): MAC: 2, PHY: 14, SFP+: 6
PMD: eth_ixgbe_dev_init(): port 0 vendorID=0x8086 deviceID=0x10fb
Total number of attached devices: 1
Interface name: dpdk0

kernel sysfs output:

#cat /sys/devices/pci0000:00/0000:00:05.0/0000:04:00.0/numa_node
-1

#cat /sys/devices/pci0000:00/0000:00:05.0/0000:04:00.1/numa_node
-1

# numactl --show
policy: default
preferred node: current
physcpubind: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
cpubind: 0 1
nodebind: 0 1
membind: 0 1

# numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 2 4 6 8 10 12 14
node 0 size: 40317 MB
node 0 free: 38699 MB
node 1 cpus: 1 3 5 7 9 11 13 15
node 1 size: 32166 MB
node 1 free: 30706 MB
node distances:
node   0   1
  0:  10  20
  1:  20  10
