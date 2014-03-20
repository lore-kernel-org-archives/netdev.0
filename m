From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: openvswitch question
Date: Thu, 20 Mar 2014 06:26:37 -0400
Message-ID: <CACP96tRY6frA9gfxZCMucKjd3zdCFMUgqKQtTB8umPmqYeRkYw@mail.gmail.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
	<CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ratheesh kannoth <ratheesh.ksz@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:45801 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757017AbaCTK0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 06:26:38 -0400
Received: by mail-lb0-f169.google.com with SMTP id q8so450061lbi.0
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 03:26:37 -0700 (PDT)
In-Reply-To: <CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 9:36 PM, Jesse Gross <jesse@nicira.com> wrote:
evel/19402
>
> From the perspective of the network stack, there is no difference
> between Open vSwitch internal devices and real NICs so the entry
> points into the stack are the same.

However, the internal vswitch ports like patch-tun and patch-int
are not standard net_devices, so they cannot, e.g.,  be tcpdump'ed,
correct?

FWIW, I've already raised an issue with tcpdump/ovswitch mirroring
 in the openstack-dev list, but repeat
it here, in the hope that someone can shed some light on what
I need to make this work. I'm using a ubuntu 13.10 qemu-kvm
where I'm running openvswitch 1.10.2.

" I'm following the instructions at
  http://docs.openstack.org/trunk/openstack-ops/content/network_troubleshooting.html

  to set up patch-tun mirrors, but running tcpdump on the "snooper0"
  produces inconsistent results- sometimes, I'm able to get a copy
  of the packet (e.g., the syn packet for ssh below) but not others
  (the tcpdump session did not show any more packets, for example).

  Why is this?

--------------------tcpdump on snooper0-------------------------

root@sowmini-virtual-machine:~/devstack# tcpdump -i snooper0 -xenvv
tcpdump: WARNING: snooper0: no IPv4 address assigned
tcpdump: listening on snooper0, link-type EN10MB (Ethernet), capture
size 65535 bytes
12:15:04.106523 fa:16:3e:1d:eb:b8 > fa:16:3e:e2:be:81, ethertype
802.1Q (0x8100), length 78: vlan 1, p 0, ethertype IPv4, (tos 0x0, ttl
63, id 51325, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.12.41.48975 > 10.0.0.4.22: Flags [S], cksum 0xabdb
(correct), seq 3145500194, win 29200, options [mss 1460,sackOK,TS val
64704095 ecr 0,nop,wscale 7], length 0
        0x0000:  0001 0800 4500 003c c87d 4000 3f06 9c69
        0x0010:  c0a8 0c29 0a00 0004 bf4f 0016 bb7c 8622
        0x0020:  0000 0000 a002 7210 abdb 0000 0204 05b4
        0x0030:  0402 080a 03db 4e5f 0000 0000 0103 0307
12:15:04.109993 fa:16:3e:e2:be:81 > ff:ff:ff:ff:ff:ff, ethertype
802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len
6), IPv4 (len 4), Request who-has 10.0.0.1 tell 10.0.0.4, length 28
        0x0000:  0001 0806 0001 0800 0604 0001 fa16 3ee2
        0x0010:  be81 0a00 0004 0000 0000 0000 0a00 0001
