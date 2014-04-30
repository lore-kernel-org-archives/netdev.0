From: Erik Hugne <erik.hugne@ericsson.com>
Subject: tcp: how to prevent connection abort due to failed keepalive?
Date: Wed, 30 Apr 2014 16:22:15 +0200
Message-ID: <20140430142214.GB5108@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Anders Franzen <anders.franzen@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:56179 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaD3OWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 10:22:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way to disable connection termination due to failed TCP keepalives?
I was hoping that it would be possible to use TCP_KEEPCNT == 0 for this purpose,
but this gave back an -EINVAL.

There's nothing in the RFC that claims that closing the connection if the peer
fails to respond to _all_ probes, just that:

(RFC1122 section 4.2.3.6)
	It is extremely important to remember that ACK segments that
	contain no data are not reliably transmitted by TCP.
	Consequently, if a keep-alive mechanism is implemented it
	MUST NOT interpret failure to respond to any specific probe
	as a dead connection.

So, if we have a connection with TCP_KEEPCNT set to 1, and the peer fails to
respond to this "specific probe". I think the RFC is pretty clear that the
connection shall not be considered dead. In this case, Linux send a TCP RST
and aborts the connection.

//E
