From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 3/3] net: sctp: Add partial support for
 MSG_MORE on SCTP
Date: Tue, 15 Jul 2014 14:33:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17273C31@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB7@AcuExch.aculab.com>
 <53C04509.70304@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D17271E0B@AcuExch.aculab.com>
 <53C42C58.3050108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38282 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751867AbaGOOes convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 10:34:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21580-10 for <netdev@vger.kernel.org>;
 Tue, 15 Jul 2014 15:34:39 +0100 (BST)
In-Reply-To: <53C42C58.3050108@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich 
> On 07/14/2014 12:27 PM, David Laight wrote:
> > From: Vlad Yasevich
> > ...
> >>> +	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
> >>> +	 * This means that the user can't force bundling of the first two data
> >>> +	 * chunks.  It does mean that all the data chunks will be sent
> >>> +	 * without an extra timer.
> >>> +	 * It is enough to save the last value since any data sent with
> >>> +	 * MSG_MORE clear will already have been sent (subject to flow control).
> >>> +	 */
> >>> +	if (msg->msg_flags & MSG_MORE)
> >>> +		sp->tx_delay |= SCTP_F_TX_MSG_MORE;
> >>> +	else
> >>> +		sp->tx_delay &= ~SCTP_F_TX_MSG_MORE;
> >>> +
> >>
> >> This is ok for 1-1 sockets, but it doesn't really work for 1-many sockets.  If one of
> >> the associations uses MSG_MORE while another does not, we'll see some interesting
> >> side-effects on the wire.
> >
...
> > I don't think this is a problem.
> 
> Not, it is not a _problem_, but it does make MSG_MORE rather useless
> in some situations.  Waiting for an ACK across low-latency links
> is rare, but in a high-latency scenarios where you want to utilize the
> bandwidth better with bundling, you may not see the gains you expect.
> 
> Since MSG_MORE is association, it should be handled as such and an
> a change on one association should not effect the others.

I think the comments already say that it is only a partial implementation.
(If you send 2 chunks on an idle connection, they get sent separately.)
Perhaps I'll add a note about possibly 'odd' effects for 1-many sockets
with multi-threaded apps.

It helps a lot for my M3UA traffic.
I can get the same effect on an old kernel by repeatedly changing SCTP_NODELAY,
but that does rather rely on the way Nagle is implemented.

	David
