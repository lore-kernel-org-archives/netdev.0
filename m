From: David Miller <davem@davemloft.net>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 15:55:12 -0800 (PST)
Message-ID: <20100217.155512.109075614.davem@davemloft.net>
References: <1266449678.17794.160.camel@bigi>
	<20100217.154009.78177059.davem@davemloft.net>
	<1266450553.17794.165.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756690Ab0BQXy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 18:54:57 -0500
In-Reply-To: <1266450553.17794.165.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 17 Feb 2010 18:49:13 -0500

> On Wed, 2010-02-17 at 15:40 -0800, David Miller wrote:
> 
>> Please do, your changes are reverted so I need the whole
>> thing back.
> 
> np.
> Q: Something odd i noticed when looking at pfkey (different behavior
> from netlink):
> 
> pfkey_sendmsg() does at the end:
> return err ? : len;
> 
> So if err was 0, it will always return the length which is
> 16 in the flush which was causing the EAGAIN Alexey saw. If i returned
> the correct error (ESRCH), it goes unfiltered.
> It sounds to me that should just unconditionaly return err, no?

I don't think any sendmsg() method should return 0 when something
was actually sent.
