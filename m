From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/6 v2] skb paged fragment destructors
Date: Thu, 5 Jan 2012 17:27:31 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF35@saturn3.aculab.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48035 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755401Ab2AER1V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:27:21 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23522-05 for <netdev@vger.kernel.org>;
 Thu,  5 Jan 2012 17:27:17 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> The mail at [0] contains some more background and rationale but
> basically the completed series will allow entities which inject pages
> into the networking stack to receive a notification when the stack has
> really finished with those pages (i.e. including retransmissions,
> clones, pull-ups etc) and not just when the original skb is finished
> with, which is beneficial to many subsystems which wish to inject
pages
> into the network stack without giving up full ownership of those
page's
> lifecycle. It implements something broadly along the lines of what was
> described in [1].

If you are doing that, then the network drivers must ensure they
free such skb as soon as the transmit completes - rather than
deferring the 'end of tx' processing until some later time.

Without that the sending code can't reuse the 'page' for another
request - which is one of the things I presume this allows.

(We had issues with this on SVR4 with STREAMS buffers allocated
with esballoc()...)

	David
