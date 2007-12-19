From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 20:32:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712192016280.24742@kivilampi-30.cs.helsinki.fi>
References: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
 <Pine.LNX.4.64.0712191424360.31652@kivilampi-30.cs.helsinki.fi>
 <83a51e120712190938j7c7a2c23xbe5c9da050d9956@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50783 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbXLSSdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 13:33:01 -0500
In-Reply-To: <83a51e120712190938j7c7a2c23xbe5c9da050d9956@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Dec 2007, James Nichols wrote:

> > > And the problem almost instanteaously resolved itself and outbound
> > > connection attempts were succesful.
> >
> > New or the pending ones?
> 
> I'm fairly sure that sockets that were already open in SYN_SENT state
> when I turned tcp_sack off started to work as the count of sockets in
> SYN_SENT state drops very rapidly.

Heh, "very rapidly" :-/, considering that you have 200 x SYN_SENT flows 
and if tcp_syn_retries is set to default, you will see something happening 
quite quickly for sure and the whole situation is over in ~3 mins if I 
counted correctly.

> > > Is there a kernel buffer or some data structure that tcp_sack uses
> > > that gets filled up after an extended period of operation?
> >
> > SACK has pretty little meaning in context of SYNs, there's only the
> > sackperm(itted) TCP option which is sent along with the SYN/SYN-ACK.
> >
> > The SACK scoreboard is currently included to the skbs (has been like
> > this for very long time), so no additional data structures should be
> > there because of SACK...
> 
> I've been seeing this problem for about 4 years, so could it be
> related to the scoreboard implementation somehow?

Scoreboard has no meaning in this context, it is used while _input_ 
packets are processed. If you don't get SYN-ACKs at all, it doesn't
have any meaning.

> > /proc/net/tcp couple of times in a row, try something something like
> > this:
> >
> > for i in (seq 1 40); do cat /proc/net/tcp; echo "-----"; sleep 10; done
> 
> I can set up to do this the next time the problem occurs.

for i in $(seq 1 40); ... is the right way to do the loop. :-)

> > > I'm running kernel 2.6.18 on RedHat, but have had this problem occur
> > > on earlier kernel versions (all 2.4 and 2.6).
> >
> > I've done some fixes to SACK processing since 2.6.18 (not sure if RedHat
> > has backported them). Though they're not that critical nor anything in
> > them should affect in SYN_SENT state.
> 
> Ok, unless there is direct evidence that there is a fix to this
> problem in a later kernel I won't be able to upgrade.  If there is a
> redhat provided patch I can probably do that.

...They won't affect in SYN_SENT.

-- 
 i.
