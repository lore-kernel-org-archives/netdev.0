From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 21:26:36 +0900
Message-ID: <200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp>
References: <200904211954.GGC13036.FFJLtOMHOVSOQF@I-love.SAKURA.ne.jp>
	<20090421.035731.200252490.davem@davemloft.net>
	<200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
	<20090421.044053.155783771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:58822 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbZDUM0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 08:26:39 -0400
In-Reply-To: <20090421.044053.155783771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I am saying that you shouldn't be dropping connections like
> this.
Please don't assume that we are talking about labeled networking.
I want to implement TCPwrapper-like filtering (which is automatically linked to
all processes).

> You've already accepted the packet, you cannot reneg on this.
TCPwrapper accepts the packet before it decides to drop the connection.

> You must either allow the socket to have the connection with
> current labels or give it a label appropriate for the socket.
The socket_post_accept() hook is not designed for modifying labels of a socket.
It is too late to modify because we have already accepted the packet.

+ * @socket_post_accept:
+ *	This hook allows a security module to filter connections from unwanted
+ *	peers based on the process accepting this connection.
+ *	The connection will be aborted if this hook returns nonzero.
+ *	This hook is not designed for updating security attributes of
+ *	an accept()ed socket, for the accept()ed socket has already sent
+ *	several packets (e.g. TCP's SYN/ACK packet and some ACK packets for
+ *	incoming data) before this hook is called.
+ *	@sock contains the listening socket structure.
+ *	@newsock contains the newly created server socket for connection.
+ *	Return 0 if permission is granted.
