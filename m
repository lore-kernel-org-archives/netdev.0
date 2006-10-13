From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 22:41:53 -0700
Message-ID: <17711.10017.437640.120171@localhost.localdomain>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
	<452E69B2.4030306@hp.com>
	<469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"Martin Schiller" <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:60673 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1750783AbWJMFmx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 01:42:53 -0400
To: "Caitlin Bestler" <caitlin.bestler@gmail.com>
In-Reply-To: <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caitlin Bestler writes:
 > More to the point, on what basis would the application be rejecting a
 > connection request based solely on the SYN?

Perhaps not the reason that Martin is interested in but ...

Say you are writing a transparent proxy i.e. when a TCP connection is
made through the box, rather than forwarding the TCP SYN, it is
delivered locally where it accepted and then the proxy makes a
separate TCP connection to original IP address.  Thus all traffic
flows through a user-space proxy that can cache, log, virus scan,
... etc. the traffic.  Say also that the proxy is for a protocol that
can mediate peer<->peer connections via a server (e.g. most IM
protocols).  Furher still assume that the client has the property that
if while trying to establish a peer<->peer connection it will back off
and use the server if it does not manage to establish the peer<->peer
TCP connection but if it does establish the connection then it will
not back off to use the server.  Thus if a client is behind the
transparent proxy the proxy terminates the TCP connection locally and
at that point the client thinks it has connected to the peer even
though the proxy has yet to establish a connection to the peer.

Should the proxy fail to do so all it can do is drop the
client<->proxy connection at which point the client does not connect
via the server and the user of the client is not happy since if the
proxy wasn't there everything would have worked just fine.  So, if the
proxy could delay the SYN/ACK until it has determined whether it can
really connect to the IP address in the SYN, then it can decide
whether to SYN/ACK or just not respond.

Of course, the much simpler solution is to fix the client program so
that it will still back off to the server even if it does manage to
make a TCP connection.  However, fixing other people's software is
easier said than done.  So if you are trying to $ell a tranparent
proxy solution, you need to handle it somehow.  Delayed SYN/ACK is one
such way, though not necessarily the best way.
