From: David Miller <davem@davemloft.net>
Subject: Re: question on sky2 driver panic
Date: Mon, 15 Oct 2007 22:20:32 -0700 (PDT)
Message-ID: <20071015.222032.78710839.davem@davemloft.net>
References: <4713CAEE.6010106@nortel.com>
	<20071015150408.22f31d77@freepuppy.rosehill>
	<47144920.4010402@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761787AbXJPFU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 01:20:27 -0400
In-Reply-To: <47144920.4010402@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Mon, 15 Oct 2007 23:16:16 -0600

> Our version of the e1000 passes 200 bytes in the initial chunk, and the 
> rest in fragments.  tipc currently handles that without any difficulty.

There is no requirement for any bytes to be in the initial skb->data
chunk, in fact the Neptune NIU driver only pulls the ethernet header
into there for example.

net/tipc/eth_media.c:recv_msg() seems to dereference buf->data
directly without making any pskb_may_pull() checks, and that is
a bug.

