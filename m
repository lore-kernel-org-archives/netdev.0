From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Fri, 4 Feb 2011 21:43:14 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102042126440.28937@melkinpaasi.cs.helsinki.fi>
References: <20110202.170750.229739784.davem@davemloft.net> <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi> <AANLkTinkwzts5ysW26fHqX4u89Q=kW2kSOArqL=o6RLM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1589942756-1296848594=:28937"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	Jerry Chu <hkchu@google.com>
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33735 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab1BDTnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 14:43:15 -0500
In-Reply-To: <AANLkTinkwzts5ysW26fHqX4u89Q=kW2kSOArqL=o6RLM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1589942756-1296848594=:28937
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 3 Feb 2011, H.K. Jerry Chu wrote:

> On Thu, Feb 3, 2011 at 2:43 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > It would perhaps be useful to change receiver advertized window to include
> > some extra segs initially. It should be >= IW + peer's dupThresh-1 as
> > otherwise limited transmit won't work for the initial window because we
> > won't open more receiver window with dupacks (IIRC, I suppose Jerry might
> > be able to correct me right away if I'm wrong and we open window with
> > dupacks too?).
> 
> Sorry I don't know how the receive window is updated in Linux,
> autotuning or not.
> But I just wonder why would it have to do with dupacks, i.e., why would 
> it not slide forward as long as the left edge of the window slides 
> forward, regardless of OOO pkt arrival?

?? DupACK by defination does not slide the left edge?!? :-) ...It
certainly makes a difference whether the ACK is cumulative or not. 
Anyway, I tcpdumped it now and confirmed that advertized window is not 
advanced if OOO packet arrives.

> I am of the opinion that rwnd is for flow control purpose only thus should be
> fully decoupled from the cwnd of the other (sender) side. Therefore
> initrwnd should
> normally be based on projected BDP and local memory pressure, e.g., 64KB, not
> bearing any relation with IW of the other side. Only under special
> circumstances should it be used to constrain the sender, e.g., for
> devices behind slow links with
> very small buffer.

I also think along the lines that the advertized window autotuning code 
is just unnecessarily preventive (besides the IW change, also Quickstart 
couldn't be used that efficiently because of it).

-- 
 i.
--8323329-1589942756-1296848594=:28937--
