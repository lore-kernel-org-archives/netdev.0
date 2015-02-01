From: "Zayats, Michael" <michael.zayats@hp.com>
Subject: AF_NETDEV - device specific sockets
Date: Sun, 1 Feb 2015 04:20:10 +0000
Message-ID: <FC8E8D0ECC753F45808079B18C3203FE1CCA0C@G4W3293.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:46778 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbbBAEYU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 23:24:20 -0500
Received: from G9W0364.americas.hpqcorp.net (g9w0364.houston.hp.com [16.216.193.45])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by g4t3426.houston.hp.com (Postfix) with ESMTPS id BD38466
	for <netdev@vger.kernel.org>; Sun,  1 Feb 2015 04:24:19 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am looking for a generic mechanism that would allow network device drivers to provide socket interface to user and kernel space clients.

Such an interface might be used to provide access to important sub-streams of packets, alongside with device specific packet metadata, provided through msg_control fields of recv/sendmsg.

RX Metadata might include device specific information, such as queuing priorities applied, potential destination interface in case of switching hardware etc.

On the transmission, metadata might be used to indicate hardware specific required optimizations, as well as any other transformation or accounting required on the packet.

AF_PACKET based mechanism doesn't allow metadata to be exchanged between the client and the device driver.
Extending it would require extending of sk_buff and potentially additional per packet operations.
Generic Netlink is not intended to pass packets.

As I am trying to validate generic applicability of such a mechanism, I see that TUN driver is providing custom socket interface, in order to deal with user information through msg_control.
Only usable inside the kernel, through custom interface.

Proposed interface
------------------
Kernel side: 
(struct proto *) should be added to struct net_device.
Device driver that is interested to support socket interface would populate the pointer.

User space: 
After creating AF_NETDEV socket, the only successful operation would be setting SO_BINDTODEVICE option.
Once set, all socket operations would be implemented by calling functions, that are registered at struct proto on the appropriate net_device.

What do you think?
Would you see a better approach?
Some other mechanism that already exists for such a purpose?

Thanks,

Michael
