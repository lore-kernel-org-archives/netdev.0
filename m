From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each
 CHUNK is too aggressive
Date: Fri, 24 Jun 2011 10:42:51 -0400
Message-ID: <20110624144251.GC9222@canuck.infradead.org>
References: <20110624101535.GB9222@canuck.infradead.org>
 <4E0495C3.30102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58973 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755791Ab1FXOmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 10:42:54 -0400
Content-Disposition: inline
In-Reply-To: <4E0495C3.30102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 09:48:51AM -0400, Vladislav Yasevich wrote:
> I believe there was work in progress to change how window is computed.  The issue with
> your current patch is that it is possible to consume all of the receive buffer space while
> still having an open receive window.  We've seen it in real life which is why the above band-aid
> was applied.

I don't understand this. The rwnd _announced_ is sk_rcvbuf/2 so we are
reserving half of sk_rcvbuf for structures like sk_buff. This means we
can use _all_ of rwnd for data. If the peer announces a a_rwnd of 1500
in the last SACK I expect that peer to be able to handle 1500 bytes of
data.

Regardless of that, why would we reserve a sk_buff for each chunk? We only
allocate an skb per packet which can have many chunks attached.

To me, this looks like a fix for broken sctp peers.

> The correct patch should really something similar to TCP, where receive window is computed as
> a percentage of the available receive buffer space at every adjustment.  This should also take into
> account SWS on the sender side.

Can you elaborate this a little more? You want our view of the peer's receive
window to be computed as a percentage of the available receive buffer on our
side?
