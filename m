From: Rick Jones <rick.jones2@hp.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Thu, 14 Jul 2011 09:45:46 -0700
Message-ID: <4E1F1D3A.1030204@hp.com>
References: <4E1DC83C.3020506@genband.com>	<1310579520.2509.17.camel@edumazet-laptop>	<4E1DDE62.3080503@hp.com> <4E1DEEF9.7040901@genband.com> <4E1F0345.8020108@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:45257 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755316Ab1GNQps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 12:45:48 -0400
In-Reply-To: <4E1F0345.8020108@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> In our case we don't need to actually be connected, just be listening
>> and ready to either accept() a connection or connect() to someone else.
>
> It turns out that the application people really do want the server side
> to be able to listen() at the same time as calling connect() from the
> same address/port, so Rick's testcase was accurate.

So, we are left asking "Why do the application people want that?"  Does 
the server connect() to pseudo-random places, or does it only ever 
connect back to clients which have already connected to it?

If the desire is to have the same well-known port number involved in all 
connections to/from the server (perhaps for simplistic firewall rules 
involving serverip.magicport?) then if the connections are back to the 
clients, the clients could simply open listen endpoints bound to the 
magic port number and the firewall rule become "server IP is source or 
destination) AND (magic port is source or destination)" - assuming the 
clients aren't bind()ing to the magic port number before connect()ing to 
the server.

rick jones
