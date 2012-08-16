From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 0/7] TCP Fast Open client
Date: Thu, 16 Aug 2012 09:50:05 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB6@saturn3.aculab.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <sivasankar@cs.ucsd.edu>, <netdev@vger.kernel.org>
To: "Yuchung Cheng" <ycheng@google.com>, <davem@davemloft.net>,
	<hkchu@google.com>, <edumazet@google.com>, <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43628 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756512Ab2HPIwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 04:52:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21383-03 for <netdev@vger.kernel.org>;
 Thu, 16 Aug 2012 09:52:38 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1342645307-17772-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This comment is a bit late but ...

> ...
> This patch series implement the client functionality of TCP Fast Open.
> TCP Fast Open (TFO) allows data to be carried in the SYN and SYN-ACK
> packets and consumed by the receiving end during the initial
connection
> handshake, thus providing a saving of up to one full round trip time
> (RTT)
> compared to standard TCP requiring a three-way handshake (3WHS) to
> complete before data can be exchanged.
> ...
> To use Fast Open, the client application (active SYN sender) must
> replace connect() socket call with sendmsg() or sendto() with the new
> MSG_FASTOPEN flag. If the server supports Fast Open the data exchange
> starts at TCP handshake. Otherwise the connection will automatically
> fall back to conventional TCP.

It seems wrong to be using sendmsg() to perform a 'connect' action.
Anything that tries to monitor the socket state from a trace, or
validate the sequence of library calls will get it all wrong.

IMHO this should be a new connect_xxx() function - and probably
a new system call entry.

This is similar to the complete fubar where sctp abuses setsockopt().

For development hacking using sendmsg() probably avoided the need
to hack at some code paths, but I'm sure it will cause grief in
the long term.

Other OS may have much more difficultly in abusing sendmsg().

	David
