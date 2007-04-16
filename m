From: Sebastian Kuzminsky <seb@highlab.com>
Subject: Re: bug in tcp?
Date: Mon, 16 Apr 2007 17:05:42 -0600
Message-ID: <E1HdaGU-0001sZ-JS@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <20070416155038.3bfa5104@freekitty>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc12.comcast.net ([216.148.227.152]:49331 "EHLO
	rwcrmhc12.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbXDPXFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 19:05:45 -0400
In-reply-to: <20070416155038.3bfa5104@freekitty> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Mon, 16 Apr 2007 16:28:22 -0600
> Sebastian Kuzminsky <seb@highlab.com> wrote:
> 
> > I'm seeing some weird behavior in TCP.  The issue is perfectly
> > reproducible using netcat and other programs.  This is what I do:
> > 
> >     1.  Open a TCP connection over the loopback (over IPv4).
> > 
> >     2.  Send a couple of bytes of data each way.  No problems.
> > 
> >     3.  Wait about 120 hours with no writes on either side of the
> >         connection.
> > 
> >     4.  write() a few bytes to the server's socket.  I'd expect the data
> >         to go through, but it doesnt.  I see the TCP frame from the
> >         server to the client, but instead of an ACK, the client sends
> >         back a RST.  netstat shows the bytes sitting in the server's
> >         socket's send-buffer.
> > 
> >     5.  write a few bytes to the client's socket.  The server gets
> >         these immediately.
> > 
> >     6.  On the next server-to-client retransmit, the client gets the
> >         bytes from the server.  After this, the connection works normally.
> > 
> > 
> > The libpcap capture file is here (only shows steps 4-6):
> > 
> >     http://highlab.com/~seb/tcp-idleness-bug
> > 
> > 
> > The behavior is reproducible on all kernels I've tried: 2.4.32, 2.6.19.1,
> > and 2.6.20.4.  I dont think it's iptables-related, though I'm rerunning
> > the tests on a machine without iptables to be sure.  I'll have results
> > for you in 120 hours.  ;-)
> > 
> > 
> 
> What server? Some servers do application timeouts.

I've observed the behavior with the server mode of nc, and with a homebrew
application which does not do app-level timeouts.

But anyway, application timeouts wouldnt explain the described behavior,
afaik.


-- 
Sebastian Kuzminsky
