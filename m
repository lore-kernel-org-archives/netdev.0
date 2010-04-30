From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Thu, 29 Apr 2010 23:39:58 -0700 (PDT)
Message-ID: <20100429.233958.212393607.davem@davemloft.net>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45954
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933665Ab0D3Rxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:53:35 -0400
In-Reply-To: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 29 Apr 2010 23:07:54 -0700 (PDT)

> Implement SO_TIMESTAMP{NS} for TCP.  When this socket option is enabled
> on a TCP socket, a timestamp for received data can be returned in the
> ancillary data of a recvmsg with control message type SCM_TIMESTAMP{NS}.
> The timestamp chosen is that of the skb most recently received from
> which data was copied.  This is useful in debugging and timing
> network operations.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

That's not what you're implementing here.

You're only updating the socket timestamp if the SKB passed into
the update function has a more recent timestamp.

There is nothing that says the timestamps have to be increasing and
with retransmits and such if it were me I would want to see the real
timestamp even if it was earlier than the most recently reported
timestamp.

I don't know, I really don't like this feature at all.  SO_TIMESTAMP
is really meant for datagram oriented sockets, where there is a
clearly defined "packet" whose timestamp you get.  A TCP receive can
involve hundreds of tiny packets so the timestamp can lack any
meaning.

All these new checks and branches for a feature of questionable value.
If you can modify you apps to grab this information you can also probe
for the information using external probing tools.

Sorry, I don't think I'll be applying this.
