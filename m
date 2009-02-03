From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: BUG: NIU driver: strange issues with multicast "UDP: short packet"
Date: Tue, 03 Feb 2009 14:38:20 +0100
Message-ID: <1233668300.20497.49.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:48548 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbZBCNiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 08:38:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have this strange issues with multicast and the NIU driver (Sun
neptune Quad NIC).  When receiving multicast traffic the kernel log
spams with something like this:

  __ratelimit: 5071 callbacks suppressed
  UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
  UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  __ratelimit: 3555 callbacks suppressed
  UDP: short packet: From 81.161.2.106:0 49320/1324 to 233.123.173.7:0
  UDP: short packet: From 81.161.2.106:0 49320/1324 to 233.123.173.7:0
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
  UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931

Tcpdumping the packets, the contents of the packets are correct.

The next strange thing is that I can make the log messages go away, if I
setup a static multicast route out another interface.

  smcroute -a eth52 81.161.2.106 233.123.173.7 eth21

Any hints whats going wrong?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
