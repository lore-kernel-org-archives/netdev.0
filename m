From: paul bilke <fsmail@conspiracy.net>
Subject: Re: Udp packets received with improper length
Date: Mon, 28 Nov 2011 15:23:52 -0600
Message-ID: <4ED3FBE8.2010006@conspiracy.net>
References: <4ECD540C.60108@conspiracy.net>
Reply-To: fsmail@conspiracy.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway12.websitewelcome.com ([67.18.137.84]:43773 "EHLO
	gateway.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752053Ab1K1VvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:51:25 -0500
Received: from phantom.websitewelcome.com (phantom.websitewelcome.com [174.120.148.130])
	by gateway.websitewelcome.com (Postfix) with ESMTP id 126455B42B882
	for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 15:23:55 -0600 (CST)
In-Reply-To: <4ECD540C.60108@conspiracy.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2011 2:14 PM, paul bilke wrote:
> We recently updated an embedded powerpc platform from 2.6.32 to 2.6.37.  When deployed in the field devices with the new kernel have started receiving truncated UDP packets from their mates across noisy links.  To test we wrote a simple client and
> server.  The client sends 512 byte packets with a sequence number to the server listening on a UDP socket.  On the client box we use netem to corrupt 100% of the packets sent(after transferring some data so arp cache is populated).  The server then
> dumps the length received and the serial number from any packets that are received.   Netem sometimes corrupts bits in the source MAC address so these packets arrive with valid UDP checksums and are delivered to the user application.   With the
> server running on the 2.6.32 box we send a few million packets to it and only receive packets that are exactly 512 bytes long.  When we do the same on the box running 2.6.37 we receive hundred of short packets, zero length and also 504 byte packets.
> When I use TCPdump on the box running 2.6.37 the truncate packets have valid checksums (Source MAC was corrupted by NETEM) and are of proper length (554 byte ethernet frame, 540 Byte IP portion and 520 byte UDP length) but the userland receives 504
> or 0 length in recvfrom. To see if this was just a powerpc related issue I repeated the test on x86 virtual machines.  A vm running 2.6.18 (Centos 5) receives only 512 byte packets.  On a vm running 2.6.40 (Fedora 15) I receive 512, 504 and 0 length
> packets.
<clip>

Reverting commit 81d54ec8479a2c695760da81f05b5a9fb2dbe40a makes this problem disappear. The patch looks sane, the results are problematic.
Paul Bilke
