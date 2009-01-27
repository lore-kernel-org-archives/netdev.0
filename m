From: David Miller <davem@davemloft.net>
Subject: Re: port bound SAs
Date: Mon, 26 Jan 2009 22:20:35 -0800 (PST)
Message-ID: <20090126.222035.100955508.davem@davemloft.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>
	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@centrify.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbZA0GUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:20:38 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul Moore" <paul.moore@centrify.com>
Date: Mon, 26 Jan 2009 11:21:33 -0800

> A few weeks ago I posted a question to the IETF IPsec group on this
> topic 
> 
> I have 2 SPDs declared saying (transport mode)
> 10.0.0.0/24 port 23 esp
> 10.0.0.0/24 port 80 esp
> 
> I then initiate a connection from that Linux machine to another system
> that has the same logical rules
> port 23 fires up and I get an SA pair. The question is - does that SA
> pair belong to port 23 or not
> If I now connect using port 80 from the same Linux box to the same peer
> it tries to use the SA already set up for port 23
> The remote system (windows in my test case) drops the packets because it
> believes that the SA is for port 23 traffic only

Why does the Linux system do this?  The route lookup should, as it's
final IPSEC route lookup action, do an xfrm policy lookup which should
do a selector match and thus not match the port 23 rule.

I can't find the code which would allow the sequence of events
you describe, can you?
