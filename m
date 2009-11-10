From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: More info on SO_TIMESTAMPING problems in V6
Date: Tue, 10 Nov 2009 14:03:19 -0500
Message-ID: <4AF9B8F7.5090509@ripnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ripnet.com ([66.78.99.10]:3277 "EHLO mx1.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbZKJTFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 14:05:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like there *isn't* support on the V6 side for SO_TIMESTAMPING.

The ipv6/udp.c  calls the V4 udp_sendmsg when the packet is a "V4 on a 
V6 socket", but otherwise
   the necessary "goop" doesn't appear to be implemented for V6.

In particular, the V4 udp_sendmsg function has a structure, ipcm_cookie, 
which appears to
   be used to carry the shtx flags, including the "hardware" flag that 
indicates hardware
   timestamping.  It's not clear exactly where this gets "attached" to 
the outgoing SKB, but
   none of this appears in the V6 version of udp.c

While the V6 udp.c is quite *similar* to the V4 version, some of the 
data structures are
   quite different, and it's not clear to me where to begin.  Further, I 
got a note from Patrick
   Ohly indicating that the e1000 driver guys at Intel have been the 
ones maintaining the
   SO_TIMESTAMPING code, so I don't want to replicate work that may 
already be in-progress/
   done.

Looking at even the latest kernel code, there's no hint that this has 
been addressed.

Also, there's no hint of implementation for net/packet (AF_PACKET).

The context of all this is a PTPV2 (IEEE1588-2008) implementation that 
requires hardware time-stamping support for all three of: IPV4, IPV6, 
and ETHERNET (AF_PACKET/SOCK_DGRAM).

I've been testing with IPV4 exclusively, and it has been working quite well.
