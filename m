From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Sun, 23 Dec 2007 01:42:14 -0500
Message-ID: <476E0346.1030902@garzik.org>
References: <20071223053314.GA31966@havoc.gtf.org> <20071223062731.GP8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41687 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXLWGmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 01:42:19 -0500
In-Reply-To: <20071223062731.GP8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> On Sun, Dec 23, 2007 at 12:33:14AM -0500, Jeff Garzik wrote:
>> A couple [minorly] notable wireless bug fixes, and plenty of viro fixes
>> for obscure issues :)
> 
> Heh...  FWIW, forcedeth patch (sent your way about two weeks ago) also
> belongs in the same set.  If you need a resend - tell...

I applied it to #upstream (2.6.25) since forcedeth is not on any 
big-endian platforms AFAIK.

Is it .24 material for some obvious reason, which I missed?  :)


> There's another pile in drivers/net/wireless, but that's for linville to
> forward when he gets around to it.  Pure annotation patches belong to
> past-2.6.24 merge.
> 
> I also have starfire and epic100 fixes, but that'll have to wait until
> I get around to putting the cards into sparc box (mcast breakage for
> starfire and full-driver one for epic100; since nobody had cared for
> the latter since 2.3.late, well...)

I have an epic100 card too if you need it (though it sounds like you 
have something testable).


> I think I'll have an ipg fix for you tomorrow, but I want to RTFM first
> to make sure that it makes sense.  And there are several interesting
> issues in atl1, netxen and cxgb3, but those will have to wait for when
> I get around to asking maintainers just what the hell did they mean those
> to do.
> 
> FWIW, drivers/net is fairly noise-free wrt sparse endianness warnings
> in my tree; the main exceptions are prism54 (oid_mgt.c and the nightmares
> it pulls) and skfp (AIX-shared vendor driver; 'nuff said, IMO).

Awesome :)


> BTW, if you still have any documentation for xircom_cb from your fighting
> tulip-related stuff, it would be welcome - there are some oddities with
> rx ring handling (assuming that we care about that driver at all and it's
> not on the way out, that is).

xircom_tulip_cb should probably be deleted, since it is the crappier of 
the two drivers for the same hardware (xircom_cb being the other one).

xircom_cb _the driver_ is pretty odd.  It is less like tulip than it 
should be, actually.  There are several things that could have been done 
to improve the throughput/etc. of the driver, but it was more important 
at the time to simply find a driver that always worked.  IIRC its RX 
filtering was broken, implying the need to enable promisc mode just to 
receive packets normally.

	Jeff



