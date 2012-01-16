From: Arvid Brodin <arvid.brodin@enea.com>
Subject: HSR: Standard breaks alignment. Solution?
Date: Tue, 17 Jan 2012 00:10:30 +0100
Message-ID: <4F14AE66.7060301@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:22115 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751068Ab2APXKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 18:10:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I've written before here, I'm trying to add support for the HSR protocol
("High-availability Seamless Redundancy") to the linux kernel. The protocol is
specified in IEC-62439-3, and involves adding a protocol tag after the ethhdr
on outgoing frames, and stripping it again on reception, much like VLAN.

This HSR tag is 6 bytes long, which breaks 32-bit header alignment and causes
an Oops and a kernel panic in icmp_echo on the receiving side of pings (here,
exactly: http://lxr.linux.no/#linux+v2.6.37/net/ipv4/icmp.c#L838 )

If I add two bytes of padding to the HSR tag everything works beautifully. But
of course that breaks any pretense of standard compliance.

Is there some way to fix this without having to memmove the whole frame payload
2 bytes on reception?

Or is this alignment-breaking specification crappy enough to break it and keep
the padding? (I don't really care, I only need this to work between linux
machines.) A "HSR-like" redundancy protocol. :-|

-- 
Arvid Brodin
Enea Services Stockholm AB
