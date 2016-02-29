From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Question on switchdev
Date: Mon, 29 Feb 2016 16:43:16 -0500
Message-ID: <56D4BB74.2010109@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <jiri@resnulli.us>, <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:33647 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbcB2VnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 16:43:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri, Scott, or other switchdev experts,

TI Keystone netcp h/w has a switch. It has n slave ports and 1 host port. Currently the netcp driver disables the switch functionality which makes them appear as n nic ports. However we have requirement to add switch support in the driver. I have reviewed the experimental driver documentation Documentation/networking/switchdev.txt and would like to understand it better so that I can add this support to keystone netcp driver.

NetCP h/w has a 1 (host port) x n (slave port) switch. It can do layer 2 forwarding between ports. In the switch mode, host driver provides the frame to the switch and switch uses the filter data base (AKA ALE table, Address Learning Engine table) to forward the packet. There is a piece of information available per frame (meta data) to decide if frame to be forwarded to a particular port or use the fdb for forward decisions. I see following description in the above documentation.

===From Documentation/networking/switchdev.txt==================
On switchdev driver initialization, the driver will allocate and register a struct net_device (using register_netdev()) for each enumerated physical switch port, called the port netdev.  A port netdev is the software representation of the physical port and provides a conduit for control traffic to/from the controller (the kernel) and the network, as well as an anchor point for higher level constructs such as bridges, bonds, VLANs, tunnels, and L3 routers.  Using standard netdev tools (iproute2, ethtool, etc), the port netdev can also provide to the user access to the physical properties of the switch port such as PHY link state and I/O statistics.
=================================================================

1. How does port netdev differ from regular netdev that carries data when registering netdev? Any example you can point to? 
2. I assume port netdev will appear as an interface in ifconfig -a command and it is not assigned an IP address. Correct?
3. with 1xn switch, so we have n + 1 netdev registered with net core? I assume, only 1 netdev is for data plane and the rest are control plane. Is this correct?
4. We have bunch of port specific configuration that we would like to control or configure from use space using standard tools. For example, switch port state, flow control etc. Is that possible to add using this framework? ethtool update needed for this?
5. This feature is marked as experimental. Hope having more drivers added to this switch dev framework can eventually get this out of experimental to regular status. Right?

I have more questions that I will defer for now. It would be great if I can work with you to implement this in netcp driver. Hope you can respond with your comment.

Thanks.
-- 
Murali Karicheri
Linux Kernel, Keystone
