From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 13:03:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807241253150.24801@wrl-59.cs.helsinki.fi>
References: <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
 <Pine.LNX.4.64.0807241233130.24801@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1464026672-1216893813=:24801"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, w@1wt.eu,
	David Miller <davem@davemloft.net>, davidn@davidnewall.com,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37247 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbYGXKDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 06:03:34 -0400
In-Reply-To: <Pine.LNX.4.64.0807241233130.24801@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1464026672-1216893813=:24801
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 24 Jul 2008, Ilpo Järvinen wrote:

> On Thu, 24 Jul 2008, Herbert Xu wrote:
> 
> > Ingo Molnar <mingo@elte.hu> wrote:
> > >
> > > the client (running 2.6.24) does periodic 120 seconds retransmits:
> > > 
> > > 07:40:48.255452 IP dione.39201 > phoenix.distcc: . 1608:2144(536) ack 1 win 584007:40:48.255547 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
> > > 07:40:48.255564 IP dione.39201 > phoenix.distcc: . 67143:67679(536) ack 1 win 5840
> > > 07:40:48.255648 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
> > > 07:42:48.255440 IP dione.39201 > phoenix.distcc: . 2144:2680(536) ack 1 win 5840
> > > 07:42:48.255559 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
> > > 07:42:48.255570 IP dione.39201 > phoenix.distcc: . 67679:68215(536) ack 1 win 5840
> > > 07:42:48.255659 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
> > > 07:44:48.255436 IP dione.39201 > phoenix.distcc: . 2680:3216(536) ack 1 win 584007:44:48.255570 IP phoenix.distcc > dione.39201: . ack 3216 win 65535
> > > 07:44:48.255585 IP dione.39201 > phoenix.distcc: . 68215:68751(536) ack 1 win 5840
> > > 07:44:48.255669 IP phoenix.distcc > dione.39201: . ack 3216 win 65535
> >
> > OK, something's seriously screwed up on dione's kernel.  Could
> > you please disable syncookies (which should enable SACK for you)
> > and see if the problem goes away?
> 
> This looks like the FRTO bugs we fixed in 2.6.25.7, afaik, 2.6.24.y wasn't 
> anymore updated at that time so it's a bit obsolete...

But there might be something very interesting on the opposite end change 
that is pointed out by this behavior, since one needs considerable amount 
of losses in the outstanding window to triggers long delays (the bug was 
that FRTO never fallback to go-back-n retransmissions, so one RTO was 
necessary per loss), like you found out there's slow progress made and the 
situation can resolve (by a big cumulative ACK once all losses are 
cleared). Would the receiver for some reason not accept the new data 
segment that FRTO sends after getting the ACK of the retransmissions,
the RTO loop would continue forever with FRTO bug (unless userland tears 
the connection down).


-- 
 i.
---696208474-1464026672-1216893813=:24801--
