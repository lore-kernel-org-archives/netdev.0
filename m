From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 6 Dec 2007 13:30:20 +0100
Message-ID: <200712061330.20586.stefan@loplof.de>
References: <200712061156.48810.stefan@loplof.de> <200712061235.06025.stefan@loplof.de> <20071206.033909.76192198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.190]:8374 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbXLFM34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 07:29:56 -0500
In-Reply-To: <20071206.033909.76192198.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 6. Dezember 2007 12:39 schrieb David Miller:

> > Because you just will put enough RAM modules into you server when
> > setting up a scalable system.
>
> This suggestion is avoiding the important semantic issue, and
> won't lead to a real discussion of the core problem.

When writing applications for unix operating systems, it is known since ages 
that stuff can be swapped out and that even things like memory accesses can 
block. So it does not really surprise when a system call has to wait for 
memory - just imagine the kernel code for connect() could be and has been 
swapped out.

Even with moderate swap activity, this memory should be available in much less 
than one second. If on the other hand the system is already threshing, it is 
no difference if it does so within connect() or while reaching the connect() 
system call in the application flow.

Btw, this is where admin responsibility to size their systems kicks in.

So where I would draw the line: connect() is clearly a network related 
function. Therefore, if a nonblocking connect() has to sleep for a local, 
controllable resource like memory to become available, this is ok. Maybe it 
shouldn't wait for a 128MB buffer if someone configured such an abonimation, 
haven't thought deeply about that. But when being told not to wait the 
connection to complete, it should never ever wait for another network related 
activity like IPSEC SA setup to complete, especially not for hours.

IMHO this is what developers expect, and is also consistent with the fact that 
POSIX does not define O_NONBLOCK behaviour for local files.

Stefan
