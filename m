From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Tue, 24 Apr 2012 11:21:18 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
References: <1335213446.5205.65.camel@edumazet-glaptop> <1335234012.5205.97.camel@edumazet-glaptop> <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi> <20120424.041018.1514311596818654005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-965622654-1335255678=:735"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47102 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756007Ab2DXIVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:21:20 -0400
In-Reply-To: <20120424.041018.1514311596818654005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-965622654-1335255678=:735
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 24 Apr 2012, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 24 Apr 2012 11:01:37 +0300 (EEST)
> 
> > Why not, but wouldn't it be nicer to coalesce them already in GRO below 
> > with an assumption that GRO is likely to find some "mss" equivivalent 
> > which tells the gap between consecutive ACK (or even SACK) seqnos?
> 
> GRO must be able to precisely reproduce the input stream if the packet
> is forwarded and therefore we end up resegmenting on output with GSO.

I'm aware of this.

> That makes this a non-starter since we must therefore remember all of
> the SACK boundaries in the original packets.

GRO works because TCP tends to use rather constant MSS, right? ...Since 
ACKs and SACKs are nothing more than reflection of those MSS boundaries of 
the opposite direction I don't find that as impossible as you do because 
the same kind of "mss" assumption can be applied there. But GRO has made 
this somewhat messier now because the receiver doesn't any more generate 
ACK per MSS or ACK per 2*MSS but that could be "fixed" by offloading the 
ACK sending when responding to a GROed packet.


-- 
 i.
--8323329-965622654-1335255678=:735--
