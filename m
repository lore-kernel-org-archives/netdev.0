From: David Laight <David.Laight@ACULAB.COM>
Subject: SCTP connect() both ways
Date: Mon, 9 Jun 2014 09:41:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725978A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36079 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S936747AbaFIJmf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 05:42:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23636-07 for <netdev@vger.kernel.org>;
 Mon,  9 Jun 2014 10:42:25 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When SCTP is used for protocols like M3UA it seems common
to configure both port numbers for a connection (typically
to the same value).

Rather than having one system call connect() and the other
listen(), both systems really want to try to establish the
connection by sending out INIT chunks.

The connection then gets established as soon as the second of the
two systems attempts to establish it.

However if the remote system responds with an ABORT (or maybe
an ICMP error is received) the Linux SCTP stack immediately
reports 'connect failed'.
For these sorts of connections it would be much better if the
received ABORT just increased the retry timer to large value.

Thoughts?

	David
