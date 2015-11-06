From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 6 Nov 2015 19:31:35 +0000
Message-ID: <20151106193135.GW22011@ZenIV.linux.org.uk>
References: <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com>
 <20151029145847.GA10859@netbsd.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CBC66C8@AcuExch.aculab.com>
 <20151030210943.GJ22011@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CBCC02B@AcuExch.aculab.com>
 <20151104162735.GS22011@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CBCD484@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'David Holland' <dholland-tech@netbsd.org>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	"Casper.Dik@oracle.com" <Casper.Dik@oracle.com>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53058 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161211AbbKFTb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 14:31:57 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBCD484@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 06, 2015 at 03:07:30PM +0000, David Laight wrote:

> > Oh, _lovely_.  So instead of continuation of that write(2) going down
> > the throat of something opened by unrelated thread, it (starting from a
> > pretty arbitrary point) will go into the descriptor the closing thread
> > passed to dup2().  Until it, in turn, gets closed, at which point we
> > are back to square one.  That, of course, makes it so much better -
> > whatever had I been thinking about that made me miss that?
> 
> Do I detect a note of sarcasm.
> 
> You'd open "/dev/null" (lacking a "/dev/error") and use that as the source fd.
> So any writes (etc) would be discarded in a safe manner, and nothing will block.

... and never close that descriptor afterwards?  Then why would you care whether
dup2() blocks there or not?  Are you seriously saying that there is any code
that would (a) rely on that kind of warranty and (b) not be racy as hell?

Until now everyone had been talking about that thing as an attempt of mitigation
for broken userland code; you seem to be the first one to imply that this can
be used as a deliberate technics...
