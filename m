From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Antw: Re: Q: need effective backlog for listen()
Date: Tue, 09 Dec 2014 08:01:40 +0100
Message-ID: <5486AC64020000A1000183D0@gwsmtp1.uni-regensburg.de>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
 <1418056540.384.5.camel@niobium.home.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <phil@fifi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta2.uni-regensburg.de ([194.94.155.52]:50540 "EHLO
	rrzmta2.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbaLIHBm convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:1>);
	Tue, 9 Dec 2014 02:01:42 -0500
Received: from rrzmta2.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 4389752F6E
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2014 08:01:41 +0100 (CET)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta2.uni-regensburg.de (Postfix) with ESMTP id 10ECC52001
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2014 08:01:40 +0100 (CET)
In-Reply-To: <1418056540.384.5.camel@niobium.home.fifi.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Philippe Troin <phil@fifi.org> schrieb am 08.12.2014 um 17:35 in Nachricht
<1418056540.384.5.camel@niobium.home.fifi.org>:
> On Mon, 2014-12-08 at 13:51 +0100, Ulrich Windl wrote:
>> (not subscribed to the list, plese keep me on CC:)
>> 
>> I have a problem I could not find the answer. I suspect the problem
>> arises from Linux derivating from standard functionality...
>> 
>> I have written a server that should accept n TCP connections at most.
>> I was expecting that the backlog parameter of listen will cause extra
>> connection requests either
>> 1) to be refused
>> or
>> 2) to time out eventually
>> 
>> (The standard seems to say that extra connections are refused)
> 
> The argument to listen() specifies how many connections the system is
> allow to keep waiting to be accept()ed.
> As soon as you accept() the connection, the count is decremented.
> So that won't help for your use case.
> 
>> However none of the above see ms true. Even if my server delays
>> accept()ing new connections, no client ever sees a "connection
>> refused" or "connection timed out". Is there any chance to signal the
>> client that no more connections are accepted at the moment?
> 
> Close the listening socket.  No new connections will be accepted.
> When you reopen the socket for accepting new connections, you may have
> to use SO_REUSEADDR before bind()ing to the port.

This is what I had done, but those connections who are waiting to be accepted: If I close the listening socket, will the clients see a connection abort, or will they see a connection refused?
Connection aborts could confuse clients.

Ulrich
