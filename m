From: David Miller <davem@davemloft.net>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Mon, 18 Feb 2008 16:35:54 -0800 (PST)
Message-ID: <20080218.163554.74130592.davem@davemloft.net>
References: <47BA0984.2070306@cybernetics.com>
	<1203381120.13495.78.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tonyb@cybernetics.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751203AbYBSAfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 19:35:18 -0500
In-Reply-To: <1203381120.13495.78.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 18 Feb 2008 16:32:00 -0800

> On Mon, 2008-02-18 at 17:41 -0500, Tony Battersby wrote:
> > I am experiencing network data corruption with a 3Com 3C996B-T NIC
> > (Broadcom NetXtreme BCM5701; driver tg3.ko).  I have identified the
> > following patch as the trigger:
> 
> Assuming this problem is unique to the 5701, I'm not sure how it is
> exposed by Herbert's patch.  One thing unique on the 5701 is that it
> double-copies all RX packets so that the data starts at offset 2, but
> that's quite unrelated to the patch below.

One consequence of Herbert's change is that the chip will see a
different datastream.  The initial skb->data linear area will be
smaller, and the transition to the fragmented area of pages will be
quicker.
