From: David Laight <David.Laight@ACULAB.COM>
Subject: shutdown()'s 'how' parameter doesn't seem to be used correctly
Date: Wed, 26 Feb 2014 15:18:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CB847@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46561 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751114AbaBZPTG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 10:19:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24422-01 for <netdev@vger.kernel.org>;
 Wed, 26 Feb 2014 15:19:04 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAICT userspace calls shutdown(sock, how) with 'how' set to one of SHUT_RD (0),
SHUT_WR (1) or SHUT_RDWR(2).

The kernel code typically wants the bitmask of RCV_SHUTDOWN (1) | SEND_SHUTDOWN (2).
If you look at the af_unix.c unix_shutdown() there is a comment where it
add's one in order to do the conversion.

But I can't find the conversion before tcp_shutdown() or sctp_shutdown()
checks for 'how & SEND_SHUTDOWN'.
Which implies that shutdown(sock, SHUT_WR) doesn't work.

What have I missed?
Should I be passing 2 or 3 to a direct call to sock->ops->shutdown()?
(We currently pass 2 - which does outward disconnect anyway).

	David
