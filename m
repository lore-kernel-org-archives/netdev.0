From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Tue, 24 Apr 2012 13:32:34 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204241323550.735@wel-95.cs.helsinki.fi>
References: <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi> <20120424.042546.2154907239944513463.davem@davemloft.net> <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi> <20120424.044837.771495850418417499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1576193486-1335263554=:735"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53666 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab2DXKcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 06:32:36 -0400
In-Reply-To: <20120424.044837.771495850418417499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1576193486-1335263554=:735
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 24 Apr 2012, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 24 Apr 2012 11:40:27 +0300 (EEST)
> 
> > And the problem I mentioned in the previous mail (in the terms of this 
> > code fragment) is that ackdiff is no longer MSS or 2*MSS because of GRO 
> > for the opposite direction doesn't trigger all those ACKs a non-GRO 
> > receiver would.
> 
> And in any event, you cannot depend upon the ACK boundaries in any way
> shape or form, 2 * MSS is just one valid mode of ACK'ing.
> 
> Whether we get a GRO stretch ACK or a normal 2 * MSS one, it has to
> work properly either way.

I don't see how any of this is that much different from the data side. x 
bytes, x bytes, x bytes, ... (typically x=MSS) is just one valid mode of 
data sending, and yet the GRO is currently based on this one mode only. 
...It of course works properly also when that is not true but won't work 
as efficiently as when the size remains the same.


-- 
 i.
--8323329-1576193486-1335263554=:735--
