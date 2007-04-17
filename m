From: Philip Craig <philipc@snapgear.com>
Subject: Re: bug in tcp?
Date: Tue, 17 Apr 2007 14:44:53 +1000
Message-ID: <462450C5.5080702@snapgear.com>
References: <E1HdZgM-0001n2-F0@highlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Kuzminsky <seb@highlab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:47105 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753925AbXDQFEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 01:04:43 -0400
In-Reply-To: <E1HdZgM-0001n2-F0@highlab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Kuzminsky wrote:
> I'm seeing some weird behavior in TCP.  The issue is perfectly
> reproducible using netcat and other programs.  This is what I do:
> 
>     1.  Open a TCP connection over the loopback (over IPv4).
> 
>     2.  Send a couple of bytes of data each way.  No problems.
> 
>     3.  Wait about 120 hours with no writes on either side of the
>         connection.
> 
>     4.  write() a few bytes to the server's socket.  I'd expect the data
>         to go through, but it doesnt.  I see the TCP frame from the
>         server to the client, but instead of an ACK, the client sends
>         back a RST.  netstat shows the bytes sitting in the server's
>         socket's send-buffer.
> 
>     5.  write a few bytes to the client's socket.  The server gets
>         these immediately.
> 
>     6.  On the next server-to-client retransmit, the client gets the
>         bytes from the server.  After this, the connection works normally.
> 
> 
> The libpcap capture file is here (only shows steps 4-6):
> 
>     http://highlab.com/~seb/tcp-idleness-bug
> 
> 
> The behavior is reproducible on all kernels I've tried: 2.4.32, 2.6.19.1,
> and 2.6.20.4.  I dont think it's iptables-related, though I'm rerunning
> the tests on a machine without iptables to be sure.  I'll have results
> for you in 120 hours.  ;-)

It sounds like it could easily be iptables related, if you have iptables
rules that only allow new connections in the client to server direction,
which is quite normal.

The default iptables timeout for TCP connections is 5 days.
So after 5 days of idle, any packets from the server will be treated
as a new connection and the iptables rules will drop them.
