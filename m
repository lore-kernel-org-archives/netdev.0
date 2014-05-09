From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/8] tipc: decrease connection flow control
 window
Date: Fri, 9 May 2014 13:30:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
 <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: 'Jon Maloy' <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55711 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750772AbaEINcO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 09:32:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11834-06 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 14:32:05 +0100 (BST)
In-Reply-To: <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy
> Memory overhead when allocating big buffers for data transfer may
> be quite significant. E.g., truesize of a 64 KB buffer turns out
> to be 132 KB, 2 x the requested size.

If the data is in the skb allocated by the ethernet driver then
the cumulative truesize is probably very dependent on the driver.
In some cases the value could be much higher - especially if the
drivers are fixed to report a correct truesize.

> This invalidates the "worst case" calculation we have been
> using to determine the default socket receive buffer limit,
> which is based on the assumption that 1024x64KB = 67MB buffers
> may be queued up on a socket.
> 
> Since TIPC connections cannot survive hitting the buffer limit,
> we have to compensate for this overhead.

If the connection can't survive this, then you probably have to
accept the received data anyway.
However I'd have thought you should be able to treat it as equivalent
to a lost ethernet packet.

Sounds a bit like a badly designed protocol to me...

	David
