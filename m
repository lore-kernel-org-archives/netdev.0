From: Samuel Suter <samuel.suter@mylansite.org>
Subject: Kernel 2.6.33-2 - ip -6 addr list does not show any addresses
Date: Wed, 05 May 2010 15:43:47 +0100
Message-ID: <4BE18423.6090600@mylansite.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.samhostuk.net ([81.169.142.145]:59871 "EHLO mx.samhostuk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab0EEPOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 11:14:42 -0400
Received: from mx.samhostuk.net (localhost [127.0.0.1])
	by mx.samhostuk.net (Postfix) with ESMTP id C8F281124B89
	for <netdev@vger.kernel.org>; Wed,  5 May 2010 16:44:01 +0200 (CEST)
Received: from [172.16.149.51] (host217-37-44-41.in-addr.btopenworld.com [217.37.44.41])
	by mx.samhostuk.net (Postfix) with ESMTP id 848101124B87
	for <netdev@vger.kernel.org>; Wed,  5 May 2010 16:44:01 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all

I am repeatedly hitting a problem on two of my servers running 
kernel.org 2.6.33-2 on Debian 5.0 x86_64 using the Debian 5.0 stable 
iproute package (iproute2-ss080725).

There is a clear discrepancy between the information returned by 
'ifconfig' and 'ip addr' (or 'ip -6 addr'). This server has 26 physical 
interfaces and ifconfig lists all of them with all their assigned 
addresses, but 'ip addr' only lists my loopback and one of the interfaces.

The actual problem emerges when I try and flush all addresses and add 
them again:

# ip -6 addr flush dev eth24
Nothing to flush.
# ip -6 addr add 2001:470:921b:7845::3d/64 dev eth24
RTNETLINK answers: File exists
# ifconfig eth24
eth24     Link encap:Ethernet  HWaddr 00:22:19:c4:7a:1d 
          inet addr:10.7.24.61  Bcast:0.0.0.0  Mask:255.255.255.128
          inet6 addr: 2001:470:921b:7845::77/64 Scope:Global
          inet6 addr: 2001:470:921b:7845::66/64 Scope:Global
          inet6 addr: 2001:470:921b:7845::55/64 Scope:Global
          inet6 addr: 2001:470:921b:7845::44/64 Scope:Global
          inet6 addr: 2001:470:921b:7845::76/64 Scope:Global
          inet6 addr: 2001:470:921b:7845::67/64 Scope:Global
          .
          .
          .
# ip -6 addr list dev eth24
#

This shows that 'ifconfig' knows about these addresses, but 'ip' does 
not. All the IPv6 addresses show up in /proc/net/if_inet6.
# grep eth24 /proc/net/if_inet6 | wc -l
57
# ifconfig eth24 | grep inet6 | wc -l
57

This leaves me in a situation where I an unable to flush the IP 
addresses on a device.

This problem seems to happen more often on a server running kernel.org 
2.6.33-2 kernel as opposed to the Debian patched 2.6.26, though it did 
happen with the debian kernel.

Regards

Samuel Suter
