From: Timur Tabi <timur@freescale.com>
Subject: Problems with ULI 526x driver
Date: Mon, 12 Nov 2007 12:41:54 -0600
Message-ID: <47389E72.7050907@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: peerchen@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48983 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbXKLSnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 13:43:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm trying to get the ULI 526x driver working on a Freescale 8610 reference 
board, and it can't connect.  When I turn on debug, I see this:

Configuring network interfaces...uli526x: uli526x_open 0
uli526x: uli526x_init() 0
uli526x: uli526x_descriptor_init() 0
uli526x: send_filter_frame() 0
uli526x: uli526x_set_filter_mode() 0
uli526x: Set multicast address 1
uli526x: send_filter_frame() 0
uli526x: uli526x_get_stats 0
uli526x: uli526x_set_filter_mode() 0
uli526x: Set multicast address 2
uli526x: send_filter_frame() 0
ADDRCONF(NETDEV_UP): eth0: link is not ready
uli526x: uli526x_set_filter_mode() 0
uli526x: Set multicast address 2
uli526x: send_filter_frame() 0
uli526x: uli526x_get_stats 0
uli526x: uli526x_set_filter_mode() 0
uli526x: Set multicast address 2
uli526x: send_filter_frame() 0
done.

and then some time later, I see thisL

uli526x: Link link OK 3
uli526x: eth0 NIC Link is Up 100 Mbps Full duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
uli526x: uli526x_set_filter_mode() 0
uli526x: Set multicast address 3
uli526x: send_filter_frame() 0
uli526x: uli526x_get_stats 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0

If I try to ping, I get this:

  ping 10.82.48.106
PING 10.82.48.106 (10.82.48.106) 56(84) bytes of data.
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0
 From 10.82.19.159 icmp_seq=2 Destination Host Unreachable
 From 10.82.19.159 icmp_seq=3 Destination Host Unreachable
 From 10.82.19.159 icmp_seq=4 Destination Host Unreachable
uli526x: uli526x_start_xmit 0
uli526x: uli526x_start_xmit 0


A long time ago, there was a patch for the Tulip driver that added support for 
the ULI 526x.  This support was removed in commit 
ea8f400c98ec9ae0604bc5a6721174ef68635815:

http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=commit;h=ea8f400c98ec9ae0604bc5a6721174ef68635815

Now, if I revert those changes, the Tulip driver works for me.  So there's 
something that the tulip+uli526x driver does that the stand-alone uli526x driver 
doesn't do.

Unfortunately, I don't really know anything about the tulip or uli526x drivers. 
  Is there anyone who can give me a clue as to what could be wrong?

-- 
Timur Tabi
Linux kernel developer at Freescale
