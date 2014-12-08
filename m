From: Philippe Troin <phil@fifi.org>
Subject: Re: Q: need effective backlog for listen()
Date: Mon, 08 Dec 2014 08:35:40 -0800
Message-ID: <1418056540.384.5.camel@niobium.home.fifi.org>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Windl <Ulrich.Windl@rz.uni-regensburg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from granite.fifsource.com ([173.255.216.206]:42422 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbaLHQn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:43:29 -0500
In-Reply-To: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-08 at 13:51 +0100, Ulrich Windl wrote:
> (not subscribed to the list, plese keep me on CC:)
> 
> I have a problem I could not find the answer. I suspect the problem
> arises from Linux derivating from standard functionality...
> 
> I have written a server that should accept n TCP connections at most.
> I was expecting that the backlog parameter of listen will cause extra
> connection requests either
> 1) to be refused
> or
> 2) to time out eventually
> 
> (The standard seems to say that extra connections are refused)

The argument to listen() specifies how many connections the system is
allow to keep waiting to be accept()ed.
As soon as you accept() the connection, the count is decremented.
So that won't help for your use case.

> However none of the above see ms true. Even if my server delays
> accept()ing new connections, no client ever sees a "connection
> refused" or "connection timed out". Is there any chance to signal the
> client that no more connections are accepted at the moment?

Close the listening socket.  No new connections will be accepted.
When you reopen the socket for accepting new connections, you may have
to use SO_REUSEADDR before bind()ing to the port.

Phil.
