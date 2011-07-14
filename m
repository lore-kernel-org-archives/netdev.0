From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 for 3.0
Date: Thu, 14 Jul 2011 13:53:08 +0300
Message-ID: <e3a50404b461eba3acda4dc06d238989@visp.net.lb>
References: <20110713124946.4a33190e@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38074 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327Ab1GNKxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 06:53:12 -0400
In-Reply-To: <20110713124946.4a33190e@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Just tested git iproute2 and 3.0-rc7-git1

 Tested if namespaces working:
 Tunnel ~ # uname -a
 Linux Tunnel 3.0.0-rc7-git1-build-0060 #2 SMP Thu Jul 14 13:06:32 EEST 
 2011 i686 GNU/Linux
 Tunnel ~ # unshare -n ip addr
 3: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 Tunnel ~ # ip addr
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
     inet 127.0.0.1/8 scope host lo
 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
 state UP qlen 1000
     link/ether 00:1c:c0:d3:d8:db brd ff:ff:ff:ff:ff:ff
     inet 192.168.20.20/24 scope global eth0
 Tunnel ~ #

 Then tried to used new commands:

 Tunnel ~ # ip netns add test
 Tunnel ~ # ip netns list
 test
 Tunnel ~ # ip netns exec test ls
 seting the network namespace failed: Function not implemented

 I did small patch, cause 3.0 kernel headers not distro repository yet:
 #define NETNS_ETC_DIR "/etc/netns"
 
 +#define __NR_setns 268
 
 #ifndef CLONE_NEWNET

 But still it is not working:
 Tunnel ~ # ip netns exec test /bin/sh
 fd 4 nstype 1073741824|40000000
 seting the network namespace failed: Invalid argument

 On Wed, 13 Jul 2011 12:49:46 -0700, Stephen Hemminger wrote:
> If anyone has any patches for the 3.0 version of iproute2
> now would be a good time to send them.
>
> I still have to but my netem CLG and QFQ scheduler bits, but
> there maybe other stuff that people have stashed in their distro
> patch pile.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.

