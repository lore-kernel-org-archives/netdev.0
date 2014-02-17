From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
Subject: RE: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 19:11:05 +0000
Message-ID: <D53252F45158EF44B1DF124FDC9AF2A35AD9E1FB@FEYNMAN.fokus.fraunhofer.de>
References: <1392656174-14791-4-git-send-email-sw@simonwunderlich.de>
	<5302474B.6090609@broadcom.com>
	<D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
 <20140217.140653.1309552047403078220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "arend@broadcom.com" <arend@broadcom.com>,
	"sw@simonwunderlich.de" <sw@simonwunderlich.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay04-dus.antispameurope.com ([94.100.134.204]:55587 "EHLO
	mx-relay04-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbaBQTMA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 14:12:00 -0500
In-Reply-To: <20140217.140653.1309552047403078220.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Thought so, as well. But it seems that skb->protocol is not properly
> > set when the packet originates from a packet socket.  And in our case
> > we cannot set it to a fixed etherType in the bind() call since we use
> > three different etherTypes on the same socket.
> 
> So many things break if the skb->protocol isn't set correctly that I would
> consider such SKBs mal-formed.

Agreed.

> You can specify the protocol number in the msghdr passed into the send.

Will take a look. Thx. Need to check if there is also a way to set the protocol number when using TX_RINGs, where  we use one send() call to signal the kernel that a bunch of frames (with potentially different protocol numbers) is ready for consumption.
