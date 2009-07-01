From: Florian Westphal <fw@strlen.de>
Subject: Re: [Bugme-new] [Bug 13688] New: backlog parameter of listen is
	not working with TCP
Date: Wed, 1 Jul 2009 23:10:03 +0200
Message-ID: <20090701211003.GC19223@Chamillionaire.breakpoint.cc>
References: <bug-13688-10286@http.bugzilla.kernel.org/> <20090701114932.a2f4a2e4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, florent.cloirec@free.fr
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42218 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751046AbZGAVKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 17:10:02 -0400
Content-Disposition: inline
In-Reply-To: <20090701114932.a2f4a2e4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 1 Jul 2009 18:39:07 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13688
> >            Summary: backlog parameter of listen is not working with TCP
> >            Product: Networking
[..]
> > When creating a server I usually create a socket, bind it to any address and
> > call listen to limit the queue size, then I call accept in a loop to handle
> > clients one by one.
> > 
> > In a particular case I wanted to serve only 1 client and refuse the other
> > connection attempts. I tried any value for the backlog parameter, whatever I
> > use the server is not refusing any connection, though the queue should be full.
> > The SYN+ACK handshake is completed everytime.

The behaviour depends on net.ipv4.tcp_abort_on_overflow sysctl.
If its on, new connections are reset once the backlog is exhausted.
