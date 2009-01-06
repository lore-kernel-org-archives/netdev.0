From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Tue, 6 Jan 2009 19:55:38 +0100
Message-ID: <20090106185538.GB30322@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1141 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613AbZAFSzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 13:55:45 -0500
Content-Disposition: inline
In-Reply-To: <20090106183704.GC32491@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jens,

On Tue, Jan 06, 2009 at 07:37:05PM +0100, Jens Axboe wrote:
> On Tue, Jan 06 2009, Evgeniy Polyakov wrote:
> > Hi Willy.
> > 
> > Unfortunately I can not work on this problem right now, but will do if
> > things are not resolved after Jan 11 (long vacations will be finished in
> > Russia and I will return to my test machines :) But right now I have
> > one quesstion: I read several times your mail but still can not figure
> > out if receiving or sending side is broken?
> > 
> > I.e. can you splice from socket into the file, check the file, and then
> > splice to the another socket and check received data to find out which
> > side is broken? Or did I just missed that in the problem description?
> > 
> > Thanks a lot for the test application, it will greatly help to resolve
> > this issue.
> 
> I'll give this a spin tomorrow as well. A hunch tells me that this is
> likely a page reuse issue, that splice is getting the reference to the
> buffer dropped before the data has really been transmitted. IOW, the
> page is likely fine reaching the ->sendpage() bit, but will be reused
> before the data has actually been transmitted. So once you get that far,
> other random data from that page is going out.

I like your explanation because eventhough I don't understand the code
(can't follow it past the actors in fact), I understand the problem you're
suggesting ;-)

> Just a guess, I'll try and reproduce this tomorrow!

OK. In order not to waste your time, run the test app from one interface to
the same one, with both the client and the server on the same machine, distinct
from the test app. It will trigger immediately. "nc|od -Ax -tx1" will save you
a lot of time on the client side too BTW.

Thanks,
Willy

