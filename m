From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 0/2] icmpv6_filter: correct minimum ICMPv6 message
 size
Date: Fri, 2 Aug 2013 10:50:52 -0300
Message-ID: <cover.1375417279.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:60936 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab3HBNwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 09:52:47 -0400
Received: from 201-160-231-201.fibertel.com.ar ([201.231.160.201] helo=ws)
	by hydra.openmoko.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <werner@almesberger.net>)
	id 1V5Fmc-0001ey-Ev
	for netdev@vger.kernel.org; Fri, 02 Aug 2013 15:52:43 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches correct the minimum ICMPv6 message size enforced
by net/ipv6/raw.c:icmpv6_filter

The first patch corrects a type error. Because of the error, ICMPv6
raw sockets on 32 bit systems accepted ICMPv6 messages as small as
4 bytes, while 64 bit systems required at least 8 bytes.

The second patch reduces the amount of data we require from eight
(i.e., the ICMPv6 header plus four bytes of message body) to four
bytes. This is needed for protocols like RPL (RFC 6550) that use
ICMPv6 messages with bodies smaller than four bytes.

Note that applications that assume that the kernel will not pass
such short ICMPv6 messages on raw sockets may misbehave on 64 bit
systems after applying these patches. However, even if such
applications exist, they would already have that vulnerability on
32 bit systems.

- Werner

Werner Almesberger (2):
  icmpv6_filter: fix "_hdr" incorrectly being a pointer
  icmpv6_filter: allow ICMPv6 messages with bodies < 4 bytes

 net/ipv6/raw.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

-- 
1.8.1.2
