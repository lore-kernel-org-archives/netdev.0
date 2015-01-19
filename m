From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Mon, 19 Jan 2015 09:53:41 +0100
Message-ID: <1421657621.1965.4.camel@sipsolutions.net>
References: <0397034D-1DF4-409F-B335-FCD0D7EAB940@holtmann.org>
	 <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
	 <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
	 <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60159 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbbASIxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 03:53:52 -0500
In-Reply-To: <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-18 at 18:10 -0800, Marcel Holtmann wrote:
> Hi Scott,
> 
> > This patch needs to be reverted ASAP.  git bisect landed me here also;
> > my processes are getting the OOM msgs.  What testing was done?
> > 
> > Seems someone does care that nlmsg_end() returns skb->len.
> 
> I still wonder how this affects userspace. I have not figured that
> out. Something goes wrong pretty badly somewhere.

Ugh, sorry everyone, that was clearly very careless of me.

I can explain how it breaks userspace: basically without the change to <
the dump never finishes - it'll send one message and then break on a 0
return (assuming that no message was sent), and on the next dump
iteration send the same message again (since it assumed previously it
wasn't sent). This would often send processes into a live-lock but if
the process tries to store a complete list of objects (whichever they
are) it'll have to allocate memory in this infinite loop.

johannes
