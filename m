From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 04:48:37 -0400 (EDT)
Message-ID: <20120424.044837.771495850418417499.davem@davemloft.net>
References: <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
	<20120424.042546.2154907239944513463.davem@davemloft.net>
	<alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab2DXIs7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:48:59 -0400
In-Reply-To: <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 24 Apr 2012 11:40:27 +0300 (EEST)

> And the problem I mentioned in the previous mail (in the terms of thi=
s=20
> code fragment) is that ackdiff is no longer MSS or 2*MSS because of G=
RO=20
> for the opposite direction doesn't trigger all those ACKs a non-GRO=20
> receiver would.

This is the ACK counting Eric mentioned, which we need to preserve
for the purposes of CWND growth.

And in any event, you cannot depend upon the ACK boundaries in any way
shape or form, 2 * MSS is just one valid mode of ACK'ing.

Whether we get a GRO stretch ACK or a normal 2 * MSS one, it has to
work properly either way.
