From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Re: Antw: Re: Q: need effective backlog for listen()
Date: Wed, 10 Dec 2014 08:23:46 +0100
Message-ID: <54880312020000A100018453@gwsmtp1.uni-regensburg.de>
References: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
 <1418056540.384.5.camel@niobium.home.fifi.org>
 <5486AC64020000A1000183D0@gwsmtp1.uni-regensburg.de>
 <1418137657.384.17.camel@niobium.home.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <phil@fifi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta1.uni-regensburg.de ([194.94.155.51]:56973 "EHLO
	rrzmta1.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaLJHXu convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:1>);
	Wed, 10 Dec 2014 02:23:50 -0500
Received: from rrzmta1.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 2840F44539
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 08:23:48 +0100 (CET)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta1.uni-regensburg.de (Postfix) with ESMTP id 06D3E44240
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 08:23:47 +0100 (CET)
In-Reply-To: <1418137657.384.17.camel@niobium.home.fifi.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Philippe Troin <phil@fifi.org> schrieb am 09.12.2014 um 16:07 in Nachricht
<1418137657.384.17.camel@niobium.home.fifi.org>:
> On Tue, 2014-12-09 at 08:01 +0100, Ulrich Windl wrote:
>> >>> Philippe Troin <phil@fifi.org> schrieb am 08.12.2014 um 17:35 in Nachricht
>> <1418056540.384.5.camel@niobium.home.fifi.org>:
>>
>> > The argument to listen() specifies how many connections the system is
>> > allow to keep waiting to be accept()ed.
>> > As soon as you accept() the connection, the count is decremented.
>> > So that won't help for your use case.
>> > 
>> >> However none of the above see ms true. Even if my server delays
>> >> accept()ing new connections, no client ever sees a "connection
>> >> refused" or "connection timed out". Is there any chance to signal the
>> >> client that no more connections are accepted at the moment?
>> > 
>> > Close the listening socket.  No new connections will be accepted.
>> > When you reopen the socket for accepting new connections, you may have
>> > to use SO_REUSEADDR before bind()ing to the port.
>> 
>> This is what I had done, but those connections who are waiting to be
>> accepted: If I close the listening socket, will the clients see a
>> connection abort, or will they see a connection refused?
>> Connection aborts could confuse clients.
> 
> The clients that completed the 3-way handshake and are waiting for their
> (server-side) socket to be accept()ed will see connection reset I
> believe.
> 
> You may be able to work something out by having no listen backlog
> (listen(0)) and closing and reopening the socket when needed.

I think I'd feel happier if listen() would implement the old semantics by default, and a new ioctl() (or such) would change to the "Linux accept all connections (3-way handshake) mode" on demand... Wishful thinking...

Ulrich
