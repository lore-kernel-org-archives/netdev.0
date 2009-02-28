From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Fri, 27 Feb 2009 16:10:11 -0800 (PST)
Message-ID: <20090227.161011.220557653.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F283B6220@orsmsx501.amr.corp.intel.com>
	<20090227031421.GA21036@gondor.apana.org.au>
	<80769D7B14936844A23C0C43D9FBCF0F283B712F@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeffrey.t.kirsher@intel.com,
	emil.s.tantilov@intel.com, patrick.ohly@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39562
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751902AbZB1AKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 19:10:31 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F283B712F@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Fri, 27 Feb 2009 08:39:30 -0800

> The fact is, if you are planning to kill it further up the stack,
> you can put that down as another reason for removing the call.  The
> timesync / killing skb->sk is a separate discussion that I don't
> know if I even really need to be involved in.  The patch doesn't
> break anything, and removes a call to skb_orphan that shouldn't
> really be there in the first place.

That's not true at all.

One reason we haven't removed it yet is because there are some
semantic issues to address, which are also effected by drivers
doing this kind of by-hand skb_orphan()'ing.

For one thing, if you skb_orphan() in your transmit handler,
a UDP application can take over your network card by just
transmitting in an endless tight loop.  It would be able to
nearly keep all other users from using the card.

That happens because if you skb_orphan(), nothing controls the
pace at which datagram applications can send.  Currently
we need the socket send buffer limits to help us out here,
but if you skb_orphan() you completely subvert that proptection.

So I will not apply this patch.
