From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: Suppress / delay SYN-ACK
Date: Fri, 13 Oct 2006 08:28:55 +0200
Message-ID: <000f01c6ee90$dc5ef5f0$1a04010a@V505CP>
References: <17711.10017.437640.120171@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Caitlin Bestler'" <caitlin.bestler@gmail.com>,
	"'Rick Jones'" <rick.jones2@hp.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:33978 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S1750711AbWJMG2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 02:28:54 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9D6Srf30173
	for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 08:28:53 +0200
To: "'Stephen J. Bevan'" <stephen@dino.dnsalias.com>
In-Reply-To: <17711.10017.437640.120171@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 13, 2006 7:42 AM, Stephen J. Bevan wrote:

> Say you are writing a transparent proxy i.e. when a TCP connection is
> made through the box, rather than forwarding the TCP SYN, it is
> delivered locally where it accepted and then the proxy makes a
> separate TCP connection to original IP address.  Thus all traffic
> flows through a user-space proxy that can cache, log, virus scan, ...
> etc. the traffic.  Say also that the proxy is for a protocol that can
> mediate peer<->peer connections via a server (e.g. most IM
> protocols).  Furher still assume that the client has the property
> that if while trying to establish a peer<->peer connection it will
> back off and use the server if it does not manage to establish the
> peer<->peer TCP connection but if it does establish the connection
> then it will not back off to use the server.  Thus if a client is
> behind the transparent proxy the proxy terminates the TCP connection
> locally and at that point the client thinks it has connected to the
> peer even though the proxy has yet to establish a connection to the
> peer.               
> 
> Should the proxy fail to do so all it can do is drop the
> client<->proxy connection at which point the client does not connect
> via the server and the user of the client is not happy since if the
> proxy wasn't there everything would have worked just fine.  So, if
> the proxy could delay the SYN/ACK until it has determined whether it
> can really connect to the IP address in the SYN, then it can decide
> whether to SYN/ACK or just not respond.      
> 
> Of course, the much simpler solution is to fix the client program so
> that it will still back off to the server even if it does manage to
> make a TCP connection.  However, fixing other people's software is
> easier said than done.  So if you are trying to $ell a tranparent
> proxy solution, you need to handle it somehow.  Delayed SYN/ACK is
> one such way, though not necessarily the best way. -    
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org More majordomo
> info at  http://vger.kernel.org/majordomo-info.html  

That's nearly exactly what our situation is:

The machine on which the SYN-ACK-feature should be implemented is a
TCP-to-X.25 Gateway. There are really stupid TCP terminals out there which
connects to the Gateway and simply start sending their data after the
connection between them and the Gateway is established.

The Gateway otherwise has to check its internal routing-table, which X.25
Number should be called for the requesting TCP terminal and establish this
X.25 connection.

And now here is the point:
If, why ever, the X.25 connection can't be established, the TCP-connection
to the terminal has to be closed, or even better: NOT been established at
all, so that the terminal can't send any data.

So if you ask me, how often the connections should be rejected, i have to
say: "Hopefully never", but so long as this stupid terminals will be very
confused if the connection is firstly established and than suddenly closed,
I think I can't resign this feature.



