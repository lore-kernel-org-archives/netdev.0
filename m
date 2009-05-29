From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Multicast socket option
Date: Fri, 29 May 2009 10:12:18 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0905291008300.17436@gentwo.org>
References: <4A1EC33E.1080201@us.ibm.com> <20090529103556.GA4160@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:34005 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757132AbZE2OMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 10:12:37 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1A00182C676
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 10:26:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9QBcT7MJnNar for <netdev@vger.kernel.org>;
	Fri, 29 May 2009 10:26:52 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7110582C67E
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 10:26:52 -0400 (EDT)
In-Reply-To: <20090529103556.GA4160@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 May 2009, Neil Horman wrote:

> > diff -urN linux-2.6.29.2/net/ipv4/igmp.c linux-2.6.29.2.new/net/ipv4/igmp.c
> > --- linux-2.6.29.2/net/ipv4/igmp.c	2009-04-27 13:37:11.000000000 -0400
> > +++ linux-2.6.29.2.new/net/ipv4/igmp.c	2009-05-18 16:22:33.000000000 -0400
> > @@ -2196,7 +2196,7 @@
> > 			break;
> > 	}
> > 	if (!pmc)
> > -		return 1;
> > +		return inet->mc_all;
>
> This change also filters out broadcasts sent to sockets listening on a given
> port.  Is that what you want?

Look at the beginning of the function:

   if (!ipv4_is_multicast(loc_addr))
                return 1;


will return 1 for broadcast.

