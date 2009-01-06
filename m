From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 19:50:12 +0100
Message-ID: <20090106185012.GA30322@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1138 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840AbZAFSuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 13:50:23 -0500
Content-Disposition: inline
In-Reply-To: <20090106183223.GA11964@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

On Tue, Jan 06, 2009 at 09:32:23PM +0300, Evgeniy Polyakov wrote:
> Hi Willy.
> 
> Unfortunately I can not work on this problem right now, but will do if
> things are not resolved after Jan 11 (long vacations will be finished in
> Russia and I will return to my test machines :) But right now I have
> one quesstion: I read several times your mail but still can not figure
> out if receiving or sending side is broken?
> 
> I.e. can you splice from socket into the file, check the file, and then
> splice to the another socket and check received data to find out which
> side is broken? Or did I just missed that in the problem description?

Maybe I wasn't very clear. It's only when splicing from a socket to another
socket that it breaks. Splicing from a file to a socket is OK (sendfile is
OK too BTW). Splicing from a socket to a file is OK.

And BTW, the receiving side must be on a real interface, not loopback. Here
are my observations :
  - splice data from lo to lo     => no corruption at all
  - splice data from lo to eth0   => no corruption at all
  - splice data from eth0 to lo   => occasional corruption
  - splice data from eth0 to eth0 => massive corruption

I think this may ring a bell for someone.

> Thanks a lot for the test application, it will greatly help to resolve
> this issue.

I figured it was an absolute necessity. The original code in my proxy is in
an experimental state and far too hard to debug for these purposes. It was
enough to detect the problem, but I could run a lot more tests with this
small test app ! An who know, maybe it will serve as an example for
non-blocking splice ;-)

Cheers,
Willy

