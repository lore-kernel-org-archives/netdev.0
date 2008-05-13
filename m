From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 14:33:26 -0300
Message-ID: <20080513173326.GG15306@ghostprotocols.net>
References: <20080513162325.GF15306@ghostprotocols.net> <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051AbYEMRem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:34:42 -0400
Content-Disposition: inline
In-Reply-To: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, May 13, 2008 at 09:59:35AM -0700, David Stevens escreveu:
> Arnaldo Carvalho de Melo <acme@redhat.com> wrote on 05/13/2008 09:23:25 
> AM:
> 
> > Em Tue, May 13, 2008 at 08:50:59AM -0700, David Stevens escreveu:
> > > Are they mutually exclusive?
> > > 
> > > Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving
> > 
> > Because DCCP is not SOCK_DGRAM at all? :)
> 
>         Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't really that
> either, as Remi said.
>         If you do a connect() on a UDP socket, it doesn't cease to
> be a SOCK_DGRAM socket, so I don't really care about that distinction,
> but if others do, that's ok with me. There are ACKs here, too, so maybe.

A "connection" on a UDP socket is not performed as a reliable handshake,
its just simple "hey kernel, everytime I do a write please send to this
default destination, would you do it for me?", whereas a connection on a
DCCP socket is much like the same as a TCP connection. In Linux they
share most of the connection establishment, minisocks, timewait sockets
infrastructure even.

So for connection purposes, DCCP is SOCK_STREAM, but when data is to be
transmitted it really is a SOCK_DGRAM, i.e. it is neither :)

>         My point was really that, though not as pretty, the world won't
> end if there are two ways to get to the same kind of socket, and
> especially if adding a new one makes getaddrinfo() easier to deal with.
> If the best way isn't the existing way, we could add it, and keep the
> old way for backward compatibility only.
>         A "0" protocol had better continue to be TCP and UDP, and
> specifying IPPROTO_DCCP makes it clear what the user wants, regardless

As it makes specifying a SOCK_DCCP on a patched glibc :) If someone
comes with a better name than SOCK_DCCP and keep the value already
allocated, the better, SOCK_DCCP looks too much specific to one
protocol, but it is just that there is only one specification for a
reliable connection + unreliable data transfer protocol (that I know
of).

> of the type. So "just working" (even with any of SOCK_DGRAM, SOCK_STREAM,
> and SOCK_DCCP) seems perfectly reasonable to me. My $.02.
>         A wrapper sound ok to me too.

I think that the wrapper for older libcs + patching libc to know about
this new kind of socket is the way to go.

- Arnaldo
