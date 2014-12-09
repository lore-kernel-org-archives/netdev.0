From: Philippe Troin <phil@fifi.org>
Subject: Re: Antw: Re: Q: need effective backlog for listen()
Date: Tue, 09 Dec 2014 07:07:37 -0800
Message-ID: <1418137657.384.17.camel@niobium.home.fifi.org>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
	 <1418056540.384.5.camel@niobium.home.fifi.org>
	 <5486AC64020000A1000183D0@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Windl <Ulrich.Windl@rz.uni-regensburg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from granite.fifsource.com ([173.255.216.206]:60624 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757058AbaLIPHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 10:07:38 -0500
In-Reply-To: <5486AC64020000A1000183D0@gwsmtp1.uni-regensburg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 08:01 +0100, Ulrich Windl wrote:
> >>> Philippe Troin <phil@fifi.org> schrieb am 08.12.2014 um 17:35 in Nachricht
> <1418056540.384.5.camel@niobium.home.fifi.org>:
>
> > The argument to listen() specifies how many connections the system is
> > allow to keep waiting to be accept()ed.
> > As soon as you accept() the connection, the count is decremented.
> > So that won't help for your use case.
> > 
> >> However none of the above see ms true. Even if my server delays
> >> accept()ing new connections, no client ever sees a "connection
> >> refused" or "connection timed out". Is there any chance to signal the
> >> client that no more connections are accepted at the moment?
> > 
> > Close the listening socket.  No new connections will be accepted.
> > When you reopen the socket for accepting new connections, you may have
> > to use SO_REUSEADDR before bind()ing to the port.
> 
> This is what I had done, but those connections who are waiting to be
> accepted: If I close the listening socket, will the clients see a
> connection abort, or will they see a connection refused?
> Connection aborts could confuse clients.

The clients that completed the 3-way handshake and are waiting for their
(server-side) socket to be accept()ed will see connection reset I
believe.

You may be able to work something out by having no listen backlog
(listen(0)) and closing and reopening the socket when needed.

Phil.
