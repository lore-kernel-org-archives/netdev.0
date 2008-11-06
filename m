From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Date: Thu, 6 Nov 2008 16:21:02 +0100
Message-ID: <20081106152102.GB3621@gerrit.erg.abdn.ac.uk>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net> <4909FAEF.8040900@grobelny.oswiecenia.net> <56979.148.187.160.35.1225468273.squirrel@148.187.160.35> <200811030027.43084.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35539 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751799AbYKFPYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 10:24:38 -0500
Content-Disposition: inline
In-Reply-To: <200811030027.43084.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| What about using select() call to get the effect of waiting? I think that 
| select() is precisely designed for such a thing. It is generally used on 
| reading from sockets so it could be used on writing to sockets as well. I 
| haven't looked at the code yet to know how complicated it might be to 
| implement but it seems to be a nice idea to consider.
| 
I think select() will give us similar problems - it is this very old BSD socket
interface. 

To me Posix asynchronous I/O seems to be a highly promising idea here, since it is
possible to submit a packet and then have the kernel call you back to confirm
that it has been dispatched.

I don't know the full state of AIO, it recently popped up in a configuration
menu,  http://lse.sourceforge.net/io/aio.html
