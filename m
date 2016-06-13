From: David Ahern <dsa@cumulusnetworks.com>
Subject: udp failures traced to e858fae2b0b8
Date: Sun, 12 Jun 2016 20:47:20 -0600
Message-ID: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: rppt@linux.vnet.ibm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34441 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933118AbcFMCrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 22:47:22 -0400
Received: by mail-pf0-f173.google.com with SMTP id 62so41177133pfd.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 19:47:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike:

UDP tests in my vrf unit test suite are failing. git bisect points to:


dsa@kenny:~/kernel-2.git$ git bisect good
e858fae2b0b8f41f0bed2cdffde25e7c97da38a7 is the first bad commit
commit e858fae2b0b8f41f0bed2cdffde25e7c97da38a7
Author: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date:   Wed Jun 8 16:09:21 2016 +0300

     virtio_net: use common code for virtio_net_hdr and skb GSO conversion

     Replace open coded conversion between virtio_net_hdr to skb GSO 
info with
     virtio_net_hdr_{from,to}_skb

     Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 7e53f434e2d3a50ac685ce153dd92fc1a207de0e 
470864c731ae7dd680f9807d2a1a359c715a4270 M      drivers


On console I get the following:

[   80.414134] skbuff: bad partial csum: csum=34/6 len=40
[   80.416105] eth1: bad gso: type: 0, size: 0


Nothing special on the setup -- shell scripts and qemu commands that 
have worked fine for years. Host OS is debian/jessie:

dsa@kenny:dsa-ns:~$ /usr/bin/qemu-system-x86_64 --version
QEMU emulator version 2.1.2 (Debian 1:2.1+dfsg-12+deb8u6), Copyright (c) 
2003-2008 Fabrice Bellard

Networking arg:

-netdev 
type=tap,vhost=on,ifname=vm01-eth1,script=no,downscript=no,id=netdev1
-device virtio-net-pci,mac=02:e0:f9:1c:b9:74,netdev=netdev1,romfile=

tap device is connected to a bridge.

David
