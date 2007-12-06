From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 6 Dec 2007 09:49:01 +0100
Message-ID: <200712060949.02524.stefan@loplof.de>
References: <20071204.223023.262159049.davem@davemloft.net> <200712051939.08384.stefan@loplof.de> <20071205.182500.166603251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.190]:12487 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbXLFIs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 03:48:56 -0500
In-Reply-To: <20071205.182500.166603251.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 6. Dezember 2007 03:25 schrieb David Miller:

> POSIX says nothing about the semantics of route resolution.

Of course not. Applications must not care about what happens at the transport 
layer.

> Non-blocking doesn't mean "cannot sleep no matter what".

... and as O_CREAT on open() isn't specifically documented to apply to 
filenames starting with 'a', it is perfectly normal that "echo x >ash" always 
fails since 2.6.22. To revert to the old behaviour, please do "echo 1 
>/proc/sys/fs/allow_a_file_creation".

Ok, irony aside. Just have a look at
http://www.opengroup.org/onlinepubs/009695399/functions/connect.html (I hope 
009695399 is not a personalition cookie ;-)

"If the connection cannot be established immediately and O_NONBLOCK is set for 
the file descriptor for the socket, connect() shall fail and set errno to 
[EINPROGRESS], but the connection request shall not be aborted, and the 
connection shall be established asynchronously."

I think the words "shall fail" and "immediately" are quite clear.

> > If this is changed for some IP sockets, event-driven applications
> > will randomly and subtly break.
>
> If this was such a clear cut case we'd have changed things
> a long time ago, but it isn't so don't pretend this is the
> case.

Well, the only reason this doesn't break on a daily basis is because the code 
isn't in the kernel that long and not many people run applications on an 
IPSEC gateway. This will change if kernel based IPSEC is used for roadwarrior 
connections or dnssec based anonymous IPSEC someday. Trust me, you will 
revert this misbehaviour in -stable then.

For some real life applications that break when nonblocking connect() blocks, 
please look f.e. at squid or mozilla firefox.

Stefan
