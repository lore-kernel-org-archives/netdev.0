From: Simon Chen <simonchennj@gmail.com>
Subject: stable bonding config
Date: Thu, 12 Jan 2012 21:31:44 -0500
Message-ID: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64816 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757177Ab2AMCbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 21:31:45 -0500
Received: by wgbdt14 with SMTP id dt14so904275wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 18:31:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Not sure if this is the right place to ask, but I got very good
answers about this topic in the past...

I am mostly using Ubuntu 10.10. Each server has dual intel 10G NICs,
which I want to bond. I configured the switches to support 802.3ad.
Based on this post http://ubuntuforums.org/showthread.php?t=1595177, I
configure the server as:

/home/simon# cat /etc/modprobe.d/aliases.conf
alias bond0 bonding
options bonding mode=4 miimon=100 lacp_rate=1 downdelay=200
updelay=200 ad_select=1 xmit_hash_policy=1

/home/simon# cat /etc/network/interfaces
...
auto bond0
iface bond0 inet manual
        bond-slaves none
        bond-mode 4
        bond-miimon 100
        up /sbin/ifenslave bond0 eth2 eth3
        down /sbin/ifenslave bond0 eth2 eth3

auto eth2
iface eth2 inet manual
bond-master bond0
bond-primary eth2 eth3

auto eth3
iface eth3 inet manual
bond-master bond0
bond-primary eth2 eth3

auto bond0.200
iface bond0.200 inet static
  address ...
  vlan_raw_device bond0
==========================

However, after a reboot the bonding doesn't work immediately. In particular:

/home/simon# cat /proc/net/bonding/bond0
...
802.3ad info
LACP rate: fast
Aggregator selection policy (ad_select): bandwidth
Active Aggregator Info:
        Aggregator ID: 3
        Number of ports: 2
        Actor Key: 33
        Partner Key: 19
        Partner Mac Address: 00:00:00:00:00:00 <------bonding not working
======================================

The only magic to get it work that I know of, is to perform "rmmod
ixgbe" "modprobe ixgbe" and then "ifconfig eth2 0.0.0.0 up" "ifconfig
eth3 0.0.0.0 up" "ifdown bond0" "ifup bond0".

Is there a hassle-free bonding configuration that I can use? Or some
trick that I am not aware of?

Thanks.
-Simon
